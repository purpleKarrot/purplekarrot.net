---
title: My review of the proposed C header for the Bitcoin Core Kernel API
summary: Ranges, ranges everywhere. Or why I should definitely meet TheCharlatan on a regular basis.
tags: [api, bitcoin]
---

Recently, I met
[TheCharlatan](nostr:npub196cr58e3ds70njgqul6ndm3gu4yxxjgx00sp32t95lru5k600u7q2ftlhg)
and we talked about [The Bitcoin Core Kernel](https://thecharlatan.ch/Kernel/).
Personally, I find the whole endeavor extremely interesting, and I would like to
participate in its development.

To get familiar with the
[proposed C header API](https://github.com/bitcoin/bitcoin/pull/30595), I
started implementing a
[Python extension in C](https://docs.python.org/3/extending/extending.html)
rather than loading the C API with `ctypes` or generating bindings with
[SWIG](https://www.swig.org/) or [pybind11](https://github.com/pybind/pybind11).

After working with the API for a few days and reviewing the various language
bindings listed in the PR summary, my conclusion is a NACK.

Disclaimer: I know very little about the internal implementation of bitcoin-core
(yet), but I am very familiar with and strongly opinionated about polyglot API
design. In the following, I will review the classes from a very high level. I
will not go into implementation details. I just want to see whether the provided
functions are correctly grouped into classes. I look at the C++ wrapper classes
as a kind of reference implementation for other language bindings.

The class `Transaction` does not provide any functionality beyond construction
in its public interface. This is a bit surprising.

The class `ScriptPubkey` provides access to a copy of the buffer it was
constructed with. I have an opinion on that, but I will not go into detail about
memory management in this review.

The class `TransactionOutput` is constructed with an amount and a
`ScriptPubkey`. It has accessors for those two values. This is straightforward.

The class `Block` provides access to a copy of the buffer it was constructed
with, just like `ScriptPubkey`. It also has a function to get the `BlockHash`.
It is similarly surprising, as with `Transaction`, that this class does not
provide a richer public interface.

The class `UnownedBlock` has a similar API to `Block`. If ownership were
expressed in the API, no separate class would be needed for this. I go into more
detail in a different post.

So far, the class design is rather straightforward. Next, I look at the classes
`BlockUndo`, `BlockIndex`, and `ChainstateManager`. What is a `BlockUndo`? I
cannot make any sense of that name. Maybe I will find some hints in the other
two classes.

A `BlockIndex` can be retrieved from `ChainstateManager` by the functions
`GetBlockIndexFromTip`, `GetBlockIndexFromGenesis`, `GetBlockIndexByHash`,
`GetBlockIndexByHeight`, and `GetNextBlockIndex` (when providing another
`BlockIndex`). `BlockIndex` has functions to access the previous block index,
the `BlockHash`, and the height. Interesting! I assume that by chaining
`chain.GetBlockIndexFromTip().GetHeight()`, I can get the height of the chain.

A `BlockIndex` can also be used to access a `Block` and a `BlockUndo` from the
`ChainstateManager`. But since I can get a `BlockIndex` by height, I actually
have access to both `Block` and `BlockUndo` by height.

Quick summary 1: I was surprised that `Block` does not provide much in the
public API. I could not make sense of the name `BlockUndo`. The only way to get
a `BlockUndo` is where you can also get a `Block`. Maybe the two classes should
be merged?

Quick summary 2: I know how to get the height (I call that `::size()`) and I
know how to get a `Block` by height (I call that `::operator[]`). With those two
functions in place, I can turn `ChainstateManager` into a standards-compliant
random access range. All the `BlockIndex` functionality can be replaced with
`begin`, `end`, `front`, `back`, `find`, `operator++`, `operator*`, etc.

Now, I need to take a closer look at `Block`/`BlockUndo` again. There is a
public data member `m_size`, a function that gets another size from an index,
and a function that gets a `TransactionOutput` by two indexes. This seems to be
a two-dimensional data structure, or rather a random access range of another
random access range, with `TransactionOutput` as the `value_type` of the inner
range.

Maybe `Transaction` could be the `value_type` of the outer range? This would
make sense. And it would give `Transaction` some functions in the API. We could
have `Chain` as a range of `Block`s, `Block` as a range of `Transaction`s, and
`Transaction` as a range of `TransactionOutput`s, where each `TransactionOutput`
has an amount and a `ScriptPubkey`.

Let's say, for the last five blocks with a difficulty adjustment, you need to
print the block height and the total amount of all transaction outputs. With the
API suggested in the PR, this would probably result in pages of code, with
nested loops and mutable state. But with an API that is compatible with standard
algorithms, it could be just this:

```cpp
for (auto const [height, block]
  : std::views::enumerate(chain)
  | std::views::stride(2016)
  | std::views::reverse
  | std::views::take(5)
) {
  std::println("{}: {}", height, std::ranges::fold_left(block
      | std::views::join
      | std::views::transform([](auto const& txout) { return txout.amount(); }),
    std::int64_t{0},
    std::plus{}
  ));
}
```

It is important that a C API is designed with classes, delegates, exceptions,
ownership, and ranges in mind, even though those things don't really have
meaning in C. They do have meaning in higher-level languages. If the low-level
API takes responsibility for how it should be mapped to higher-level languages,
it will not only reduce the amount of glue code required in language bindings,
it will also reduce the amount of code in client applications. Plus, it will
allow frictionless porting of client code from one language to another. As an
example, here is the corresponding code in Python:

```python
for height, block in reversed(
        deque(
            itertools.islice(enumerate(chain), 0, None, 2016),
            maxlen=5
        )):
    print(f"{height}: {sum(txout.amount for tx in block for txout in tx)}")
```

It is very likely that, at some point, we will not only be interested in the
outputs of a transaction, but also its inputs. So, rather than a `Transaction`
*being* a range of outputs, it should *have* a range of outputs. Likewise, a
`Block` should *have* a range of transactions, and even the `Chain` might
provide more information than just a range of blocks. It turns out that keeping
this extensibility in mind has a positive impact on the readability of client
code:

```python
for height, block in reversed(
        deque(
            itertools.islice(enumerate(chain.blocks), 0, None, 2016),
            maxlen=5
        )):
    print(f"{height}: {
        sum(txout.amount
        for tx in block.transactions
        for txout in tx.outputs)
    }")
```

To his credit, TheCharlatan wrote in his blog: "Especially C API design (a first
for me) was a topic I could not find many textbooks on." Got it. I will write a
series of articles about proper C API design and maybe turn them into a textbook
eventually. I will cover the following topics:

- naming conventions
- symbol visibility
- memory management
- object lifetime management
- error handling
- composability
- delegates / callbacks
- testing
- documentation
- packaging / distribution

There are a few things that I will have to figure out myself first, like how to
write language bindings for Java. But I have a clear vision of how I want things
to be. I want all the language bindings to live in a common repository, with
tests that ensure consistency between them. Also, I want to provide unified
documentation for all language bindings, with
[Code Tabs](https://sphinx-tabs.readthedocs.io/) to switch between them.

The impatient can have a look at https://github.com/purpleKarrot/btck, but
please be warned: As I experiment with things, I will constantly rewrite
history. Experimental changes will be squashed or removed. Things that I
consider ready will be split into smaller commits at some point.

I should definitely meet TheCharlatan on a regular basis to discuss the design.
