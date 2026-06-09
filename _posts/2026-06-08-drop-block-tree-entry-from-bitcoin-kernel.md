---
title: Drop BlockTreeEntry from the Bitcoin Kernel API
summary: >-
  The BlockTreeEntry type leaks internal details and couples clients to Bitcoin
  Core's implementation. The Kernel API is leaner, more stable and more robust
  without it.
tags: [api, bitcoin]
---

There are two fundamental issues with the `BlockTreeEntry` type in the Bitcoin
Kernel API.

First, the name exposes implementation details that should remain internal. A
Bitcoin node naturally maintains a tree-like structure of competing block (or
block-header) candidates while determining the best chain. However, this
internal representation is abstracted away from Kernel API clients. The API
exposes only a linear view of a chain, allowing traversal back to genesis
through repeated calls to `btck_block_tree_entry_get_previous`. Consequently,
the term `BlockTreeEntry` implies an implementation detail that is neither
visible nor relevant to API consumers.

Second, the API leaks details of the current implementation through its
traversal interface:

```c
const btck_BlockTreeEntry*
  btck_block_tree_entry_get_previous(
    const btck_BlockTreeEntry* self);
```

This function exposes the predecessor relationship as a property of an
individual `BlockTreeEntry`, effectively encoding Bitcoin Core's current
implementation into the public API. That coupling limits future refactoring,
which is precisely one of the motivations for introducing a stable kernel
interface. Ideally, relationships between blocks would be managed by an
abstraction responsible for maintaining the relevant invariants, allowing the
underlying representation to evolve without affecting API consumers.

The Bitcoin Kernel API already provides such an abstraction: `Chain`. If we view
`btck_chain_get_height` as equivalent to `Chain::size() - 1` and
`btck_chain_get_by_height` as `Chain::operator[]`, then `Chain` begins to
resemble a [sized](https://www.cppreference.com/cpp/ranges/sized_range),
[random-access](https://www.cppreference.com/cpp/ranges/random_access_range)
[view](https://www.cppreference.com/cpp/ranges/view).

Furthermore, if we interpret `btck_block_tree_entry_get_block_header` as the
equivalent of iterator dereference (`operator*`), then `BlockHeader` naturally
becomes `Chain::value_type` and `BlockTreeEntry` becomes `Chain::iterator`.
This leads to a rather elegant C++ representation in which container-like
observers such as `front()`, `back()`, `size()`, `empty()`, and `operator[]`
are deduced by the base implementation.

This raises an interesting question: should every occurrence of `BlockTreeEntry`
in the C interface correspond to `Chain::iterator` in C++?

```cpp
class Chain : public std::ranges::view_interface<Chain>
{
public:
  using value_type = BlockHeader;
  using iterator = /* ... */;

  iterator begin() const; // points to genesis
  iterator end() const;   // points past the tip

  bool Contains(iterator it) const; // ???
};

class ChainMan
{
public:
  Chain ActiveChain() const;
  std::optional<Chain::iterator>    // ???
    Find(BlockHash const& hash) const;
};
```

The problem is that an iterator alone is not a sufficient replacement for
`BlockTreeEntry`. An iterator is meaningful only relative to a particular chain.
Given a `Chain::iterator`, we cannot meaningfully traverse in either direction
without knowing the chain to which it belongs. The referenced block may be part
of a side branch rather than the active chain, and the iterator itself carries
no information about the corresponding begin and end positions.

This suggests that the appropriate replacement for `BlockTreeEntry` is not an
iterator, but a `(Chain, iterator)` pair. The Chain provides the context
required for iteration, while the iterator identifies a particular position
within that chain. Such a representation preserves the semantics of a block
reference without exposing predecessor links or block-tree nodes.

However, this immediately raises another question: what information does the
iterator contribute that is not already contained in the chain?

Given a block, there is exactly one path from genesis to that block. In other
words, every block uniquely determines a chain whose tip is that block. A
function such as

```cpp
Chain ChainMan::Find(BlockHash const& hash) const;
```

can therefore return a `Chain` ending at the requested block. The tip of the
returned chain identifies the block itself, while the remainder of the chain
provides all traversal context. The empty state observer (`operator bool()`)
inherited from `std::ranges::view_interface` naturally represents "not found",
making `std::optional` unnecessary.

From this perspective, the `(Chain, iterator)` pair collapses into a single
`Chain` object. Clients can obtain the block header via `back()`, ancestors via
`operator[]`, and height via `size() - 1`, all without exposing implementation
details of the underlying block index.

The real question is not whether `BlockTreeEntry` should become an iterator, but
whether `BlockTreeEntry` should exist in the public API at all, or whether
`Chain` is already the more fundamental abstraction.

If we replace `BlockTreeEntry` with `Chain` throughout the interface, that also
includes the function `Chain::Contains`. But since all chains begin at genesis,
the operation actually answers whether one chain is a prefix of another, even if
the implementation merely compares the block hash at height `other.size() - 1`.

This suggests that `starts_with` is the more appropriate name. The relationship
being tested is not one of generic containment, but of one chain forming an
initial segment of another. The name also has precedent in the standard library,
where `std::ranges::starts_with` expresses the same operation for arbitrary
ranges. Reusing established terminology makes the semantics immediately
recognizable to users familiar with the standard ranges vocabulary.

At the same time, there is precedent for providing a member function whose
observable behavior matches that of a generic algorithm while offering better
complexity. For example, `std::set::find` and `std::unordered_set::find`
express the same operation as `std::find`, but can exploit knowledge of the
underlying representation to avoid a linear search. Likewise,
`Chain::starts_with` could have the same semantics as
`std::ranges::starts_with` while leveraging chain-specific invariants to answer
the query in constant time. The member function therefore serves not to define
a new operation, but to provide a more efficient implementation of an existing
one.

A parallel opportunity exists for another operation. Bitcoin Core calls it
`FindFork` internally, while the corresponding standard library algorithm is
`std::ranges::mismatch`. Both identify the first position at which two sequences
diverge, which in the context of chains corresponds to the last common ancestor
before a fork.

Expressed in terms of chains, this operation determines the longest common
prefix of two chains beginning at genesis. Once again, the semantics are purely
range-based, and the result is independent of any particular internal
representation.

This suggests introducing a member function `Chain::mismatch`. As with
`starts_with`, the function would have the same observable behavior as
`std::ranges::mismatch`, but could be implemented more efficiently by exploiting
chain-specific structure (such as cached ancestry or indexed heights) rather
than performing a linear comparison from genesis.

In this sense, both `starts_with` and `mismatch` illustrate a consistent design
pattern: whenever a Kernel API operation corresponds directly to a standard
library algorithm, the API should adopt the standard name while exposing it as a
member function when the underlying domain allows for asymptotically better
implementations.

Adopting `Chain` as the primary abstraction in place of `BlockTreeEntry` yields
a cleaner, more stable, and more idiomatic Kernel API. It hides Bitcoin Core's
internal block-tree implementation details, reduces coupling, and aligns the
interface with modern C++ range concepts that developers already understand. By
embracing vocabulary and patterns from the standard library (`starts_with`,
`mismatch`, random-access views, etc.), the API becomes more intuitive,
future-proof, and easier to maintain as the underlying data structures evolve.
