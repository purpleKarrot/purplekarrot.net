---
title: >
  Making CTransaction a Regular Type
summary: >
  It's one of the most fundamental types in Bitcoin Core - and it's not a
  Regular C++ type. It can't be assigned and the comment explaining it is wrong.
  Here's how to fix it, one refactoring step at a time.
tags: [bitcoin, clang-tidy, refactoring]
---

If you open the file `src/primitives/transaction.h` in Bitcoin Core today,
you'll find this comment above the (public!) data members of `CTransaction`:

```cpp
// The local variables are made const to prevent unintended modification
// without updating the cached hash value. However, CTransaction is not
// actually immutable; deserialization and assignment are implemented,
// and bypass the constness. This is safe, as they update the entire
// structure, including the hash.
const std::vector<CTxIn> vin;
const std::vector<CTxOut> vout;
const uint32_t version;
const uint32_t nLockTime;
```

Unfortunately, this comment is inaccurate in several ways, and the approach it
justifies has significant downsides. Those are not local variables but data
members (a minor terminology issue, but worth noting). In reality,
deserialization is *not* implemented (in fact, another comment further down
states that it would be *impossible*). Assignment is also not implemented.

While the intent behind the pattern of making the data members `const` is
understandable, the C++ Core Guidelines advise
[against](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#rc-constref)
it: it makes the class *only-sort-of-copyable*, which is a subtle source of bugs
rather than a safety guarantee.

What the comment is trying to justify, is formally known as an **invariant**. An
invariant is a condition that must always hold true for an object to be in a
**valid state**. For `CTransaction`, the invariant is:

> The cached hash and witness hash must always correspond to the current
> transaction data (version, inputs, outputs, locktime, witnesses).

If someone mutates `vin` after the hash is computed, the invariant is broken:
the hash is now stale, and any code relying on `GetHash()` is operating on
incorrect data. This could lead to consensus failures. In a system like Bitcoin,
that's catastrophic. But making data members const is not the way to ensure that
the invariant holds.

The proper way to handle an invariant is a three-step discipline:

1. **Make data members private** and only give controlled access through member
   functions so that no external code can reach in and break the invariant.
   ["Minimize exposure of members"](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#rc-private).
2. **Establish the invariant in the constructor**:
   ["That's what constructors are for."](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#rc-ctor)
3. **Make sure modifier functions re-establish the invariant**: every operation
   that changes an object must leave it in a valid state.

Also worth mentioning is the guideline that if a function does not need to
access the **representation** of a class, it is better to
[not make it a member](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#rc-member):
It is better to have *fewer* functions that can cause trouble by modifying the
state of the object.

### Refactoring Step 1: Add Observer Member Functions

The first step is to add the following observer functions to `CTransaction`:

```cpp
auto GetVersion() const -> uint32_t { return version; }
auto GetInputs() const -> const std::vector<CTxIn>& { return vin; }
auto GetOutputs() const -> const std::vector<CTxOut>& { return vout; }
auto GetLockTime() const -> uint32_t { return nLockTime; }
```

The naming of those functions follows the Microsoft MFC style that is prevalent
in Bitcoin Core. My personal preference would be the standard C++ naming style
with `version`, `inputs`, `outputs`, and `locktime`. But `version` would create
a naming conflict with the data member. I also would prefer to return the inputs
and outputs as `std::span<const T>`. But this would not be compatible with
existing code that relies on `.begin()` returning a
`std::vector<T>::const_iterator`.

No behavior change yet. The data members are still public and `const`. But the
observers are now in place.

### Refactoring Step 2: Use the Observers

The second step is to write a `clang-tidy` plugin with a check that replaces all
direct member accesses with an invocation of the corresponding observer
function. This results in a commit with 484 changes. The code still compiles, no
manual additions needed.

### Refactoring Step 3: Make Data Members Private

The data members are moved to the private interface and the `const` is removed.
Now the encapsulation is real. `CTransaction` is properly copyable and movable.
It has regular value semantics.

### Refactoring Step 4: Implement Deserialization

Now that the data members are mutable, the limitation "Unserialize is not
possible, since it would require overwriting const fields" no longer holds. Care
needs to be taken that `Deserialize` must re-establish the invariant.

This is where the refactoring might stop. Mission accomplished. But there is
more:

### Refactoring Step 5: Reducing Coupling (optional and opinionated)

So far, `CTransaction` and `CMutableTransaction` are tightly coupled: They
depend on each other, as each accepts the other as an argument in the
constructor. Removing the constructor from `CTransaction` and instead adding a
conversion operator to `CMutableTransaction` makes the dependency
unidirectional.

The functions `GetValueOut()`, `ComputeTotalSize()`, `IsCoinBase()`, and
`ToString()` are implemented as members, even though they do not need access to
the private object state. Making them non-member functions would further
minimize the exposure of the data members and reduce coupling.

The functions `GetHash()`, `GetWitnessHash()`, and `HasWitness()` *concretely*
rely on the class's private bits, but *logically*, they don't. The hash of a
transaction is determined by its version, inputs, outputs, and locktime, all of
which are accessible from the public interface. The fact that the values are
cached is a pure implementation detail that is not observable from the outside.
For that reason, I personally would declare them as non-member friend functions.

### Refactoring Step 6: Optimizing Copies

Transaction objects are passed around a lot, but they are rarely modified. The
only modifying member function is `Deserialize`. Apart from that, the class can
be considered *immutable* and follows the C++ Core Guidelines for
[immutability](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#s-const).

To optimize for the use case where objects are copied more than modified, all
private members are wrapped in an internal struct and the only direct data
member of `CTransaction` is a `std::shared_ptr<const T>`. This does not change
the semantics of the type. It is still a regular value type. The difference is
that the complexity of copy becomes O(1) at the expense of an indirection for
each data member access.

### Refactoring Step 7: One Indirection

An indirection! But the truth is that an indirection was already there all
along. `CTransaction` was not used directly in most places. Instead, there is a
typedef for `CTransactionRef` that is defined as a
`std::shared_ptr<const CTransaction>`, in part as a workaround that
`CTransaction` was not a regular type. Wrapping it in a shared pointer made
assignment possible. But now `CTransaction` is a regular type and it has an
indirection internally. Of course, it is wasteful to have *two* indirections.

So the idea is to define `CTransactionRef` as an alias to `CTransaction`. What
could go wrong? It is totally expected that clients use operators `*` and `->`,
but it is possible to overload them in `CTransaction`:

```cpp
auto operator*() const -> const CTransaction& { return *this; }
auto operator->() const -> const CTransaction* { return this; }
```

Writing a clang-tidy plugin that removes the now-redundant operator `*` and
replaces `->` with a `.` is straight forward (read: I have it ready). But there
is a catch: There are more parts of `std::shared_ptr<const CTransaction>` that
clients in Bitcoin Core currently rely on apart from the operators `*` and `->`:

1. Clients initialize `CTransactionRef` with `nullptr`.
2. Clients check `CTransactionRef` for equality with `nullptr`.
3. Clients check `CTransactionRef` in a boolean context, as in `if (tx)`.
4. Clients invoke `.reset()` on `CTransactionRef`.
5. Clients invoke `.get()`, to get access to the `const CTransaction*` pointer.
6. One client invokes `.use_count()` on a `CTransactionRef`.

That last one is a single unit test. It should be removed. Unit tests for
transaction should focus on transaction behavior, not the standard library. Item
5 is a real issue. I see no reason why a pointer should be needed. This seems
like a good candidate for a follow-up cleanup.

But items 1-4 actually show that there are two different aspects of
`CTransactionRef`: Some clients assume it to be essentially `CTransaction` with
optimized copy, while others assume it as `std::optional<CTransaction>`. Going
forward, those two use-cases should be separated. And since dereferencing an
optional requires operator `*` and `->`, their replacement should be deferred.

---

That's where I am currently at. The clang-tidy checks that I mentioned are in
[bitcoin-tidy](https://github.com/purpleKarrot/bitcoin-tidy) and the cleanup
that I am experimenting with is happening in my
[vocabulary](https://github.com/purpleKarrot/bitcoin/commits/vocabulary) branch.
The end goal is [std::bitcoin](https://github.com/purpleKarrot/std-bitcoin).
