---
title: Towards a Side-Effect Free Validation Library, Part 2
summary: >-
  What would Bitcoin validation look like if it were truly side-effect free and
  built from first principles? This series explores the real boundary between
  consensus logic and node implementation details.
tags: [api, bitcoin]
---

In the
[first part](https://purplekarrot.net/blog/bitcoin-validation-library.html) of
this series, I identified that a side-effect-free validation library should
provide `block`, `block_header`, `transaction`, `outpoint`, `tx_input`,
`tx_output`, `script`, and `coin` as vocabulary types, and `chain_view` and
`coin_index` as abstractions. Based on these types, it can then provide the
following set of validation functions, all of which operate on one primary
object (`block`, `block_header`, or `transaction`) while additional arguments
provide consensus evidence. The return type indicates whether the object is
valid under the given evidence.

```cpp
verify(header);
verify(header, chain, now);

verify(tx);
verify(tx, chain);
verify(tx, chain, coins);

verify(block);
verify(block, chain, now);
verify(block, chain, now, coins);
```

Now let me go over sedited's [Validation](https://thecharlatan.ch/Validation/)
blog post once more and give a few inline comments.

## Immutable means thread-safe

> The first family of validation functions is the "Check\*"-level functions.
> These validate, among other things, the proof of work, the merkle root, size
> limits, and a few other sanity checks to ensure the block is structurally
> sound. Even though these checks are fairly cheap, a block caches internally
> whether it has passed through these checks before, and if so, skips them.

So far, so good. Those functions correspond to the *unary* `verify` functions
from my proposed API. We can see in the Bitcoin Core codebase that the mentioned
cached results are stored in the `CBlock` class as `mutable bool` variables
[here](https://github.com/bitcoin/bitcoin/blob/7802e578c3f1e9a5d9b57fb003349d0e032bb43b/src/primitives/block.h#L80).
For an example of how they are used,
[here](https://github.com/bitcoin/bitcoin/blob/7802e578c3f1e9a5d9b57fb003349d0e032bb43b/src/validation.cpp#L3969)
is how the `CheckBlock` function sets the `fChecked` flag to `true` after
successful validation and returns early when the block has already been checked
[here](https://github.com/bitcoin/bitcoin/blob/7802e578c3f1e9a5d9b57fb003349d0e032bb43b/src/validation.cpp#L3911-L3912).

Since the cache variable is `mutable` but not atomic, invoking `CheckBlock` on
the same block from multiple threads can cause a data race, leading to undefined
behavior. For a side-effect-free validation library, such a design is off the
table. Caching behavior should be excluded from the validation library, becoming
the responsibility of the caller. The caller is further encouraged to encode
successful validation in the type system rather than in a runtime state
variable.

```cpp
class CheckedBlock
{
public:
  static std::optional<CheckedBlock> Make(CBlock block) {
    if (!verify(block))
      return std::nullopt;
    return CheckedBlock{std::move(block)};
  }

  operator CBlock const&() const {
    return m_block;
  }

private:
  CheckedBlock(CBlock block)
    : m_block{std::move(block)}
  {}

  CBlock m_block;
};
```

Note that such a `CheckedBlock` utility is shown here for illustrative purposes
only. It will not be part of the validation library. It is just an example of
how such a utility could be implemented by a node implementation.

## What is an error?

> The next group is the "Accept\*"-level functions. These interact with the
> block tree, a structure where each block has a pointer to its parent, allowing
> traversal back to genesis. It may include forks, forming a tree with a long
> stem and short branches. As a subcategory, they also include the
> "ContextualCheck\*"-level functions.

That is a lot of information. Let me go through it one step at a time. But
first, I want you to refresh your memory on how [P0709](https://wg21.link/p0709)
defines an error:

> In this paper, "error" means exactly and only "a function couldn't do what it
> advertised" — its preconditions were met, but it could not achieve its
> successful-`return` postconditions, and the calling code can recover.

Now let's inspect the `AcceptBlock` function in Bitcoin Core. To me, it does not
look like a validation function with a negligible side effect. "Accept" is not a
validation level. Instead, the function's
[documentation](https://github.com/bitcoin/bitcoin/blob/7802e578c3f1e9a5d9b57fb003349d0e032bb43b/src/validation.cpp#L4286)
clearly *advertises* "Store block on disk" *without any precondition*. So if any
of the "ContextualCheck\*" functions returns false, the function will be *unable
to do what it advertised*, while *no preconditions were unsatisfied*, so the
function *has to report an error*. But that design is fundamentally flawed: an
invalid block is not an exceptional case!

My next comment is on the description of how the blocks are organized. Sure, a
node has to organize them as a tree. But this is not relevant for the purpose of
validating a block. What is relevant is the ancestry back to genesis, and this
ancestry is always *linear*. Hence, I say that validation should be defined on
an abstract `chain_view` that the caller needs to provide.

All the "ContextualCheck\*" functions should be extracted from "Accept\*" and
provided through a `verify()` function that takes a `chain_view` as validation
evidence. A node client should then encode successful validation results in the
type system using a `CheckedBlock` as shown above. `AcceptBlock` should then
require a `CheckedBlock` as input, essentially turning successful validation
into a precondition for storing the block on disk. All remaining error cases,
such as exceptions, are true runtime errors and never masquerade as validation
errors.

## Chain as a path across a tree

> Lastly, the block passes through the "Chain"-level validation functions. These
> interact with two data structures: a vector of block tree entries from genesis
> to the currently best known block for fast, height-indexed access referred to
> as `CChain`, and the UTXO set (`CCoinsViewCache`), fundamentally a mapping
> from a transaction out point to its corresponding transaction output (its
> `Coin`). This provides and unifies both a "view" into the UTXO set persisted
> on disk, and a "cache" for previously retrieved coins and coins that are spent
> within the same block.

Again, I also don't see "Chain" as a validation level. What I see are functions
that advertise effects without preconditions and then rely on error handling
when internal functions return false. Those internal functions are the ones that
a validation library should provide, so that a node can encode their results in
the type system and then use successful validation as a precondition.

While the current code interacts with two concrete data structures (`CChain` and
`CCoinsViewCache`), a standalone validation library should operate on
abstractions. I want to reinforce how I think those abstractions should be
designed and why.

As I mentioned before, I consider `chain_view` to be a
[sized](https://www.cppreference.com/cpp/ranges/sized_range),
[random-access](https://www.cppreference.com/cpp/ranges/random_access_range)
[view](https://www.cppreference.com/cpp/ranges/view) of `block_header`, which
could be type-erased with [P3411](https://wg21.link/p3411) (look in
[std::bitcoin](https://github.com/purpleKarrot/std-bitcoin) for a hand-rolled
implementation of `any_chain_view`):

```cpp
using any_chain_view = std::ranges::any_view<block_header,
  std::ranges::any_view_options::sized
  | std::ranges::any_view_options::random_access>;
```

In Bitcoin Core, the `AcceptBlock` function operates on `CBlockIndex*`, whereas
the "Chain"-level validation functions operate on `CChain`, which is essentially
a `std::vector<CBlockIndex*>` constructed by traversing the parent pointer
`pprev`. What matters is that both types provide access to the height of the
chain (`CBlockIndex::nHeight` and `CChain::Height()`), as well as access to a
`CBlockIndex*` pointer for the block at a given height
(`CBlockIndex::GetAncestor()` and `CChain::operator[]`). `CBlockIndex` contains
all the information of a `block_header`, hence both types can be wrapped in a
`chain_view` and the validation library can operate on the same level of
abstraction both when the UTXO set is available as additional context and when
it is not.

## "better name for better lookup"

The `coin_index` can be expressed as a **partial mapping** from `outpoint` to
`coin`, as I showed before, but I want to emphasize exactly why I *currently*
consider that to be the right abstraction and under what circumstances it should
be changed.

```cpp
template <typename T>
concept coin_index = requires (T const& m, outpoint p) {
  { m.lookup(p) } -> std::same_as<std::optional<coin const&>>;
};
```

At the last ISO C++ meeting in Brno, [P3091](https://wg21.link/p3091) was
accepted into the standard and [P4139](https://wg21.link/p4139) was forwarded to
LWG, which means that in C++29, all standard maps (`std::map`,
`std::unordered_map`, `std::flat_map`) will gain a lookup function that returns
an optional reference to their `mapped_type`. The name of this function is not
finalized yet, but `lookup` is currently the strongest candidate. Under those
circumstances, `std::map<outpoint, coin>` will be a valid model for
`coin_index`.

While a full node will likely use a custom data structure for the UTXO set with
multi-level caching support, it is a nice property that unit tests and tutorials
can use containers provided by the standard library. If LWG decides on a
different name, that change should be reflected in the `coin_index` concept as
well.

## Caching: Unsolvable?

> Mempool transaction validation provides further optimizations that speed up
> block validation after initial synchronization. Validating transaction scripts
> for the mempool populates two caches: the signature and the script cache.

That is tricky. My goal is to design validation that is free from side effects,
so that it can be used in a multi-threaded context without any locking. But how
does caching play into this? That is something I need to reason about.
