---
title: Towards a Side-Effect Free Validation Library, Part 3
summary: >-
  What would Bitcoin validation look like if it were truly side-effect free and
  built from first principles? This series explores the real boundary between
  consensus logic and node implementation details.
tags: [api, bitcoin]
---

In the
[first part](https://purplekarrot.net/blog/bitcoin-validation-library.html) of
this series, I argued that the central design problem for a Bitcoin validation
library is not how to extract validation from the rest of the node, but deciding
which entities should be vocabulary types and which should be represented as
abstractions. I proposed `block`, `block_header`, `transaction`, `outpoint`,
`tx_input`, `tx_output`, `script`, and `coin` as vocabulary types, with
`chain_view` and `coin_index` as the two primary abstractions — a sized,
random-access view of headers and a partial mapping from `outpoint` to `coin`,
respectively.

In the
[second part](https://purplekarrot.net/blog/bitcoin-validation-library-2.html),
I revisited Bitcoin Core's current validation architecture, argued that invalid
objects are not "errors" in the P0709 sense, and ended with the unresolved
question of how a concurrency-safe design can still support caching.

This post picks up from there. The overload set from the first part was a useful
starting point, but it didn't survive contact with the next question: how should
validation be parameterized by network? And the skepticism about `std::expected`
from part 1 — reinforced in part 2 by the distinction between validation results
and runtime errors — needed a concrete alternative. What follows is the
evolution of the design from free functions to a stateful `verifier` object, the
resolution of the return-type question, and the integration of caching and
asynchronous validation.

## From free functions to a `verifier` object

The overload set introduced in the first part and reiterated in the second was:

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

This is clean, but it has no way to carry network parameterization. Mainnet,
testnet, signet, and regtest have different proof-of-work limits, subsidy
schedules, activation heights, and feature flags. Free functions cannot carry
this without either global state or an extra argument on every call.

The solution is a **stateful function object** that binds the consensus
parameters once at construction:

```cpp
class verifier
{
public:
  constexpr explicit verifier(consensus_parameters const& params);

  auto operator()(const block&, ...) const;
  auto operator()(const transaction&, ...) const;
  // ...

private:
  consensus_parameters const* _params;
};
```

The overload set is preserved — it now lives on `operator()` — but each call is
automatically parameterized by the network whose `consensus_parameters` the
`verifier` was constructed with.

### Predefined objects per network

Each network gets its own namespace with a predefined `verify` object:

```cpp
namespace bitcoin {

namespace mainnet {
  inline constexpr auto params = consensus_parameters{ /* mainnet values */ };
  inline constexpr auto verify = verifier{params};
}

namespace testnet {
  inline constexpr auto params = consensus_parameters{ /* testnet values */ };
  inline constexpr auto verify = verifier{params};
}

namespace signet {
  inline constexpr auto params = consensus_parameters{ /* signet values */ };
  inline constexpr auto verify = verifier{params};
}

namespace regtest {
  inline constexpr auto params = consensus_parameters{ /* regtest values */ };
  inline constexpr auto verify = verifier{params};
}

inline constexpr auto verify = mainnet::verify;

} // namespace bitcoin
```

A user may write `bitcoin::verify(tx, chain, coins)` for mainnet,
`bitcoin::testnet::verify(tx, chain, coins)` for testnet, or construct a custom
`verifier` for runtime-selected parameters.

## On abstractions

The abstractions `chain_view` and `coin_index` are expressed as concepts. The
overloads of `verifier::operator()` are constrained member function templates
that forward to concrete private functions after type-erasing those
abstractions. This keeps the public API concept-based while allowing the
implementation to concentrate ABI-relevant code in non-template functions.

The alternative — making the public overloads take type-erased objects directly
— would require exposing `any_chain_view` and `any_coin_index` as part of the
public interface, which adds API surface without adding expressive power.

## Resolving the return-type question: `verify_result` instead of `std::expected`

In the first part, I expressed skepticism toward
`std::expected<Fact, verify_status>` because it frames a failed verification as
an error. I found a
[blog post](https://categorica.io/blog/2026.06.29_trust_your_compiler/#exceptions)
that recommends using `std::expected` for expected failures. It explicitly
mentions parsing, lookup, conversion, and **validation** as its primary use
cases, but it did not change my view. I propose `verify_result<Fact>` instead:

```cpp
template<class Fact>
class verify_result {
public:
  bool ok() const noexcept;
  verify_status status() const noexcept;
  Fact const& fact() const& noexcept;
  Fact&& fact() && noexcept;
};
```

On success, `ok()` is `true` and `fact()` returns the by-product (block hash,
transaction fee, undo data — the "facts" identified in part 1 as by-products of
validation). On failure, `ok()` is `false` and `status()` returns a
`verify_status` suitable for diagnostics and logging.

The key difference from `std::expected` is semantic: `verify_result` does not
carry the error-handling baggage of `std::expected`. There is no `value()` that
throws and no `error()` that frames the failure as exceptional. You check `ok()`
and proceed. A failed verification is not an error.

### Why expose `verify_status` at all?

`status()` is not there to drive control flow. The control-flow question is
already answered by `ok()`: the object is either valid or it is not.
`verify_status` exists so callers can report failed verification in logs, test
output, or operator diagnostics. For that reason, it is formattable. Consensus
rule violations remain ordinary negative results, but they can still be
described in a human-readable way when that matters.

### Exceptions are for exceptional conditions, not consensus violations

The first part referenced the 2013 chain split, where an exception path was
effectively treated as a negative verification result, contributing to
inconsistent validation behavior between nodes. That history informed the design
here: `verify_result` enforces the separation between negative validation
outcomes (values) and exceptional failures (exceptions). Consensus violations
are normal return values. Only true failures — allocation errors, *database
errors* (!!!), I/O failures — propagate as exceptions — or, in the async
overload, through the sender's error channel.

## Caching: the missing piece

The first part did not discuss caching, and the second ended by asking how it
could coexist with concurrency-safe validation. Yet caching is one of the most
important performance characteristics of Bitcoin validation. Bitcoin Core's
signature cache and script cache are why block validation is much faster than
validating the same block cold: transactions are validated when accepted to the
mempool, and the results are reused when the same transactions appear in a
block.

A `script_cache` concept can be described so that standard containers
(`std::set`, `std::unordered_set`, `std::flat_set`) are suitable models, even
though a node may use a custom cache implementation (analogous to how
`coin_index` is defined; see part 2):

```cpp
template<class T>
concept script_cache = requires (T c, script_cache_key k) {
  { std::as_const(c).contains(k) } -> std::same_as<bool>;
  { c.insert(k) };
};
```

A `verifier::operator()` overload that accepts a script cache consults it before
script evaluation and populates it after success. A cache miss is always safe —
the verifier performs full evaluation, potentially redundant but correct.

### How the mempool warms the cache

The keys are internal to the verifier — the caller never constructs or inspects
them. This doesn't prevent mempool warming, because warming happens through the
**same `verifier`**, not through a separate key-management API.

When a transaction arrives and is accepted to the mempool, the node calls the
transaction-level overload:

```cpp
// Mempool acceptance path
auto r = bitcoin::verify(tx, chain, coins, scripts);
```

The verifier constructs the `script_cache_key` internally from the data relevant
to script evaluation together with the effective rule set under which that
evaluation happens, checks the script cache (a miss, since the transaction is
new), evaluates the scripts, and on success inserts the key. The cache belongs
to the node; the verifier merely borrows it for the duration of the call.

When the same transaction later appears in a block, the node can pass the same
cache object to block validation:

```cpp
// Later, during block validation
auto r = bitcoin::verify(block, chain, now, coins, scripts);
```

The block-level overload reconstructs the same key from the same
validation-relevant data and effective rules and performs the lookup. The lookup
hits. The keys match because key derivation is pure.

The requirement is that the node uses the same cache object across both calls.
The API makes warming possible; the caller makes it happen. A node that does not
care about performance can omit the script cache entirely.

### `assumevalid`

This cache extension is already enough to express `assumevalid` without further
changes to the `verifier` class.

Bitcoin Core's `assumevalid` feature skips script validation for blocks below a
hardcoded point, while still running structural and coin-level checks. In the
proposed API, a node can express the same idea with a dummy `script_cache` whose
`contains` returns `true` unconditionally and whose `insert` is a no-op:

```cpp
struct assumevalid_script_cache {
  bool contains(script_cache_key const&) const {
    return true;
  }

  void insert(const script_cache_key&) {}
};
```

Below the configured `assumevalid` height, the node passes such a cache to block
validation. From the verifier's point of view, every script lookup is a cache
hit, so script evaluation is skipped. Above that height, the node passes its
real script cache instead. The mechanism stays entirely at the node layer:
consensus parameters remain consensus parameters, while `assumevalid` remains a
node-level optimization policy.

### The key design decision: caches are sequential, the scheduler owns concurrency

This was the hardest decision, and it went through multiple iterations. The
choice was informed by looking hard at how Bitcoin Core handles this — and
choosing to do it differently.

#### How Bitcoin Core does it

Bitcoin Core's parallel script validation uses `CCheckQueue`, a hand-rolled
master/worker thread pool. One "master" thread pushes batches of verification
jobs onto a LIFO stack protected by a `Mutex`; N-1 worker threads pop jobs and
execute them, coordinated by two condition variables. A separate
`m_control_mutex` ensures only one `CCheckQueueControl` operates at a time.

Underneath both the script cache and the signature cache sits a cuckoo-hash set
using relaxed atomics. Critically, **that primitive cache provides no thread
safety of its own**. Its documentation states outright:

1. Write requires synchronized access (e.g. a lock)
2. Read requires no concurrent Write, synchronized with last insert.
3. Erase requires no concurrent Write, synchronized with last insert.

Bitcoin Core then layers different synchronization strategies on top.
`SignatureCache` wraps the cuckoo cache in a `std::shared_mutex`, so worker
threads can consult the signature cache concurrently through a synchronized
interface. The full script-execution cache is handled differently: its use in
`CheckInputScripts()` is protected externally, today via `cs_main`.

This works. It has worked for years. It processes terabytes of transactions. But
the resulting design is still intricate: a bespoke worker queue, an underlying
cache primitive with an external synchronization contract, and two different
synchronization stories above it. That is precisely the kind of complexity
modern C++ strives to leave behind.

#### The proposed alternative: fork-join with sequential cache access

The key idea is that **cache access must always be sequential**. This implies no
thread-safety requirements, no concurrent concepts, no mutexes, no relaxed
atomic acrobatics. The async design naturally decomposes into three distinct
phases:

1. **Pre-phase (single-threaded):** Query the cache for every transaction in the
   block and, in the case of the script cache, build a vector of booleans: "is
   this transaction's script result already cached?"
2. **Parallel phase (on the scheduler):** Launch one task per transaction. Each
   task receives its transaction and the corresponding boolean. If the boolean
   is `true`, the task skips script evaluation. If it is `false`, the task
   performs script evaluation. The point of still having one task per
   transaction, even on a cache hit, is that the same task may still perform
   other per-transaction validation work or contribute to block-level facts;
   only the expensive script step is bypassed. **Tasks do not access the
   cache.** They are completely free of synchronization.
3. **Post-phase (single-threaded):** For each transaction whose scripts were
   newly evaluated, insert the corresponding key into the script cache.

This is the **fork-join** pattern: the pre-phase prepares immutable work hints,
the parallel phase performs transaction-level validation, and the post-phase
records the newly learned facts.

The scheduler owns all concurrency. Individual tasks touch no shared mutable
state. The cache needs no locks — no `Mutex`, no condition variables, and no
relaxed atomics relying on external synchronization that the compiler cannot
check.

There is a performance trade-off: a transaction validated in the parallel phase
cannot benefit from a cache entry inserted by *another* parallel task in the
same block. That is not a correctness problem, but it does give up some
intra-block reuse. The hope is that mempool warming captures most of the value,
but that is an empirical question rather than a theorem.

### A possible future extension: signature-cache buckets

A signature cache is finer-grained than a script cache. One transaction can hit
the cache several times, once per signature check, so a single boolean is not
enough. One possible extension would be to organize signature-cache entries in
per-transaction buckets:

```cpp
using signature_cache = map<wtxid, set<signature_key>>;
```

Here, `map` and `set` are expository only. An implementation may use entirely
different containers.

In the single-threaded pre-phase, the verifier would look up the bucket for each
transaction and materialize something like a `vector<set<signature_key>>` or
some equivalent representation of borrowed or extracted buckets. Each worker
would then get exclusive access to one bucket, consult and extend it without
locking, and the post-phase would merge or publish the updated buckets back into
the node-owned cache.

This combines naturally with the script cache above. A transaction task can
receive both a script-cache boolean and a signature-cache bucket. On a full
script-cache hit, the bucket is irrelevant; on a miss, the task can use the
bucket to avoid repeating individual signature checks while still recording
newly verified ones.

I nevertheless consider this a future extension, not because the model is
unsound, but because it requires profiling. There are several plausible cost
centers, and I do not know a priori which one dominates: synchronization around
a shared mutable signature cache, copying and reconciling per-transaction bucket
snapshots, or simply repeating some computation. Until that is measured, keeping
the core async design focused on the script cache seems cleaner.

## Async validation: senders and schedulers

The overload set introduced in part 1 and carried through part 2 was entirely
synchronous. Block validation, however, is the one operation that is both
parallelizable and potentially long-running. Transaction and header validation
are fast enough that async adds complexity without much benefit.

The proposed API adds one async overload — for blocks only — that accepts a
scheduler and returns a sender whose value completion delivers
`verify_result<block_fact>`:

```cpp
std::execution::sender auto work =
  bitcoin::verify(pool.scheduler(), block, chain, now, coins, scripts)
  | std::execution::then([](auto result) {
      if (result.ok()) { /* commit block */ }
      else             { /* reject */ }
    });
```

## What this design keeps and rejects

The first post framed the design as "deciding which entities belong to the
consensus vocabulary and which should be represented as abstractions," and the
second sharpened that boundary by separating validation outcomes from runtime
errors. This post adds three more lessons, some worth preserving and some worth
replacing:

**Abstractions at the boundary, concrete machinery inside.** The earlier posts
established `chain_view` and `coin_index` as abstractions. This post extends
that same idea to `script_cache`, while leaving signature caching as a possible
future extension. Callers program against concepts; any type erasure remains an
internal implementation detail. Bitcoin Core has no equivalent abstraction — its
validation functions are concrete, taking `CCoinsViewCache&` and
`const CChainParams&` directly, which makes them difficult to reuse outside
Bitcoin Core's own codebase.

**Overloading as evidence progression.** The earlier posts introduced this; this
post preserves it on `operator()`. Bitcoin Core's named-function approach
(`CheckBlock`, `ContextualCheckBlock`, `ConnectBlock`) grew organically — the
names are inconsistent, the call order is implicit, and there is no compile-time
signal that you have skipped a stage.

**The scheduler owns concurrency.** This is the area where the proposed API
diverges most sharply from Bitcoin Core. Bitcoin Core's `CCheckQueue` is a
bespoke thread pool with a `Mutex`, two condition variables, a control mutex,
and a LIFO stack of jobs. Its caching story layers synchronized wrappers and
externally synchronized cache use on top of low-level primitives. The
combination works, but it is exactly the kind of concurrency code that a
sender/receiver-style design tries to make unnecessary.

Whether the fork-join approach holds up in practice at Bitcoin Core's scale is
an open question. Bitcoin Core's approach has a long track record. But "it works
in production" is not the same as "it is the clearest interface." The
sender/receiver model was invented for a reason, and the reason is that
hand-rolled thread pools plus shared mutable caches are difficult to reason
about and verify.

## Where to from here?

At this point, I am confident that the proposed API is the right boundary. It is
useful for external clients, while at the same time satisfying the multi-stage,
caching, and concurrency requirements that Bitcoin Core itself imposes. It keeps
chainstate, mempool, and the UTXO set where they belong — in the node — and
gives validation a clean, explicit interface instead of letting node internals
leak into the consensus boundary.

The open question is no longer *what* the API should look like, but *how to get
from here to there*. In the coming days, I will publish a detailed roadmap with
individual task items that others can pick up.

I can already say this much: the first necessary step is a cleanup of the
primitive vocabulary types. They need to stop leaking implementation details,
and they need to be untangled from serialization. I have already outlined why
that matters in
[Serialization](https://purplekarrot.net/blog/serialization.html). As long as
the primitive types conflate protocol vocabulary, object layout, and
serialization machinery, a clean validation boundary remains harder to realize
than it should be.

Judging from the pushback on
[Encapsulation for `CTransaction`](https://github.com/bitcoin/bitcoin/pull/35569),
I expect this cleanup to be a multi-year effort. The objections were not subtle:
that this direction would act as a "supply-chain attack vector," that it would
waste scarce review resources on changes with "0% benefit" and "100% of the
cost," and that such refactors should not be justified on general grounds such
as C++ guidelines or literature. I do not take that as a reason to change either
the destination or the method. If validation is to have a clean boundary at all,
then the primitive vocabulary types have to stop leaking representation details
and node assumptions into every caller. That work is not optional decorative
polishing. It is prerequisite work. What the pushback changes is not the
direction, but the timescale.

The good news is that time cuts both ways. By the time the vocabulary-type
cleanup is complete, C++26 — or perhaps even C++29 — may well be broadly
available across major compilers. At that point, relying on facilities such as
`lookup` and the standard execution control library may no longer be a leap into
the future, but simply the obvious thing to do.
