---
title: Towards a Side-Effect Free Validation Library
summary: >-
  What would Bitcoin validation look like if it were truly side-effect free and
  built from first principles? This post explores the real boundary between
  consensus logic and node implementation details.
tags: [api, bitcoin]
---

At the recent Core developer meeting in Barcelona, there were several
discussions about the possibility of a side-effect free validation library. The
idea is appealing for obvious reasons: consensus validation is among the most
critical parts of Bitcoin software, yet today it lives inside a much larger
system concerned with networking, storage, chainstate management, and node
operation.

One discussion that particularly influenced my thinking was with Pieter Wuille.
While talking about validation, he explained why Bitcoin Core defers certain
expensive validation work until a side chain is promoted to the active chain.
The details are less important than the requirement this imposes: any validation
library that hopes to be useful must be capable of supporting the way Bitcoin
Core actually validates blocks. A library that is merely designed for external
consumers but not usable by Bitcoin Core itself would not be a success.

Recently, Sedited published a [blog post](https://thecharlatan.ch/Validation/)
analyzing Bitcoin Core's validation implementation. The article is valuable
precisely because it focuses on understanding the architecture that exists
today. Anyone interested in a validation library should read it first.
Understanding the dependencies present in the current system is a prerequisite
for deciding which responsibilities belong inside a consensus library and which
do not.

A common assumption is that a validation library can be obtained by extracting
existing validation code behind a cleaner API. I suspect the more interesting
question is what the API should be in the first place.

The central design problem is not how to separate validation from the rest of
the node. The central design problem is deciding which entities belong to the
consensus vocabulary and which entities should be represented as abstractions.

It is entirely possible to design a validation library around abstract notions
of blocks, transactions, scripts, and coins. Users could supply their own
concrete representations while the library operates purely on these
abstractions. Conversely, one could require users to adopt chain and UTXO
representations provided by the library. Neither choice is dictated by the
implementation. Instead, the boundary is a deliberate design decision.

My current view is that `block`, `block_header`, `transaction`, `outpoint`,
`tx_input`, `tx_output`, `script`, and `coin`, should be treated as vocabulary
types, while `chain_view` and `coin_index` should serve as the primary
abstractions.

Let me elaborate on these two abstractions, as they loosely correspond to
`CChain` and `CCoinsViewCache` in Bitcoin Core, or `HeaderAncestryView` and
`UnspentOutputsView` from Hornet -- though with some important differences.

As discussed in a previous post, I consider `chain_view` to be a
[sized](https://www.cppreference.com/cpp/ranges/sized_range),
[random-access](https://www.cppreference.com/cpp/ranges/random_access_range)
[view](https://www.cppreference.com/cpp/ranges/view) of `block_header`, which
can be expressed in C++ as:

```cpp
template <typename T>
concept chain_view = std::ranges::view<T>
  && std::ranges::sized_range<T>
  && std::ranges::random_access_range<T>
  && std::convertible_to<
       std::ranges::range_reference_t<T>,
       block_header>;
```

Unlike `CChain` in Bitcoin Core, which represents the current active chain,
`chain_view` is intended as a lightweight snapshot of the ancestry leading to a
particular block. In C++ terms, a view is a range with $O(1)$ copy complexity;
in that sense, `chain_view` is a true view, whereas `HeaderAncestryView`,
`UnspentOutputsView` (both from Hornet), and `CCoinsViewCache` (from Bitcoin
Core) are not -- despite their names suggesting otherwise.

In contrast to `HeaderAncestryView` in Hornet, which exposes the extension
points `TimestampAt`, `HashAt`, and `MedianTimePast` via virtual functions,
`chain_view` instead delegates the derivation of such properties to the
validation library itself. For example:

```cpp
auto median_time_past(chain_view auto chain) {
  assert(!chain.empty());
  auto times = chain
    | std::views::transform(&block_header::time)
    | std::views::reverse
    | std::views::take(11)
    | std::ranges::to<std::vector>();
  auto const middle = times.begin() + times.size() / 2;
  std::ranges::nth_element(times, middle);
  return *middle;
}
```

The `coin_index` abstraction, in turn, is simply a **partial mapping** from
`outpoint` to `coin`, which can be expressed in C++ as:

```cpp
template <typename T>
concept coin_index = requires (T const& m, outpoint p) {
  { m.lookup(p) } -> std::convertible_to<std::optional<coin>>;
};
```

How this lookup is implemented -- whether it uses caching, what data structure
backs it, or whether it is persisted in a database -- is entirely irrelevant to
the validation library. There might be the requirement that the lookup function
may be invoked concurrently, though.

Hornet's `UnspentOutputsView` exposes the extension points
`QueryPrevoutsUnspent` and `QueryOutPointsUnique` as virtual functions. However,
these are not merely state queries but effectively consensus decisions, which in
turn push consensus logic into the database layer. In contrast, `coin_index`
keeps a clean separation between state access and consensus logic, exposing only
a pure lookup interface over state.

With the vocabulary types and abstractions in place, and following sedited's
identification of the three stages of validation in his blog post, it becomes
straightforward to define an overload set of verification functions.

Function overloading is preferred over introducing names such as
`ContextFreeCheck` and `ContextualCheck`, since "context" is not a well-defined
abstraction. Instead, additional parameters naturally represent additional
pieces of consensus evidence, and the progression is made explicit through the
type system.

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

All these functions have a boolean outcome: the object is either valid with
respect to the provided evidence or it is not. If the object is valid,
additional information or facts may be produced as a by-product, for example
spent coins or undo data, which should be communicated back to the caller so
that state updates can be applied without recomputing the same information. If
the object is invalid, the caller may also want to know precisely which
consensus rule was violated.

Structurally, this could be modeled as `std::expected<fact, verify_status>`.
However, I am not entirely convinced this is the right abstraction. My concern
is that expected tends to frame the second alternative as an "error" in the
conventional error-handling sense, while a failed verification is not an
exceptional condition but simply one of the two normal outcomes of consensus
evaluation.

All true failures, such as allocation errors or database issues, remain
exceptional conditions and are still propagated via exceptions. As a historical
aside, the 2013 chain split is often discussed in the context of a subtle bug
where an exception path was effectively treated as a negative verification
result, contributing to inconsistent validation behavior between nodes. This
highlights why the separation between a negative validation outcome and an
exceptional condition is essential: consensus logic must remain a pure decision
process, while exceptional failures must never be allowed to masquerade as valid
semantic results of that decision.
