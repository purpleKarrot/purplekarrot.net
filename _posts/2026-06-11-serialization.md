---
title: Serialization
summary: >-
  A deep dive into rethinking Bitcoin Bitcoin serialization from first
  principles: ditching overloaded C++ machinery in favor of explicit, composable
  encoders that make every byte intentional, visible, and consensus-safe.
tags: [api, bitcoin]
---

The first step towards a freestanding, side-effect-free validation library for
Bitcoin is to expose a stable interface for the vocabulary types. The types that
currently live in `src/primitives` leak implementation details and are tightly
coupled with serialization, which is currently defined in the classes like this:

```cpp
SERIALIZE_METHODS(COutPoint, obj) { READWRITE(obj.hash, obj.n); }
```

`SERIALIZE_METHODS` is a macro that generates member functions. Calling them
"methods" is of course the smallest problem - but it's still wonderfully
telling. In proper C++ parlance, "method" is simply the wrong term, and the fact
that the macro chose that name is a delightful little red flag that extreme
pedantry was not top of mind when this system was designed.

The serialization framework itself piles on complexity. Multiple stream types
are defined in `streams.h`, which provide `operator<<` that invoke a `Serialize`
function from the global namespace. The file `serialize.h` provides multiple
overloads of the `Serialize` function - for builtin types and for standard
containers (heck, it even has a special case for `std::vector<bool>`!) - as well
as an overload that invokes a `Serialize` member function on the object.
Consequently, something as seemingly simple as `stream << object` forces the
compiler to go through **mulptiple** phases of overload resolution.

This design has a significant impact on build times. Note that `serialize.h`
pulls the headers of all containers of the standard library for all the function
overloads it provides. We can count the number of compilation units that have to
compile the serialization code with:

```sh
ninja -t deps | grep 'serialize.h' | wc -l
```

In the default build configuration, that number is 332. When the kernel is
enabled, it rises to 374. We are telling the compiler to duplicate this code
hundreds of times, only to rely on the linker to deduplicate it again. If you've
ever wondered why the builds are so slow, this is a big part of the reason. This
pattern unfortunately repeats in other parts of the codebase. We certainly don't
want to burden clients of a future validation library with this overhead.

The most fundamental problem, however, is architectural. The current design
treats the C++ class layout as the source of truth for the serialization format.
This approach assumes that the flexibility for the serialization format to
follow changes of the class layout is a desirable property, and that it is
sufficient for each version of the code to correctly roundtrip the format
defined by its own class layout. For Bitcoin, that flexibility is not a valid
use case.

What we actually need is the opposite: the serialization format must be the
source of truth, and it must be encoded explicitly in the code. The mapping
between C++ objects and their serialized representation should be fully visible
and intentional, giving us complete, bit-precise control over every serialized
byte.

This is particularly relevant in light of C++26 reflection, which makes it
increasingly natural to derive serialization directly from type structure. That
is a perfectly reasonable design for many applications. Bitcoin, however, has
different requirements: consensus defines the serialization format, not the C++
class layout. The implementation is free to evolve, but every change to the
wire format must be an explicit decision, not an incidental consequence of
refactoring.

Starting from that premise leads to a very different design. Rather than trying
to adapt or simplify the existing framework, we should discard its underlying
assumptions and derive a serialization API from first principles, with
Bitcoin's consensus requirements as the fundamental constraint.

The first abstraction we need is a writer. A writer is simply anything that
accepts a sequence of bytes:

```cpp
template <typename T>
concept Writer = requires (T& w, std::span<const std::byte> bytes) {
  { w.write(bytes) };
};
```

With that in place, the next building block is a collection of encoding
utilities. These are represented as function objects rather than functions for
two reasons: they cannot be overloaded, and they do not decay to function
pointers when passed by value.

```cpp
inline constexpr auto encode_u8 = [](auto& w, std::uint8_t v) {
  w.write(as_bytes(std::span{&v, 1}));
};

inline constexpr auto encode_u16 = [](auto& w, std::uint16_t v) {
  v = htole16(v);
  w.write(as_bytes(std::span{&v, 1}));
};

inline constexpr auto encode_u32 = [](auto& w, std::uint32_t v) {
  v = htole32(v);
  w.write(as_bytes(std::span{&v, 1}));
};

inline constexpr auto encode_u64 = [](auto& w, std::uint64_t v) {
  v = htole64(v);
  w.write(as_bytes(std::span{&v, 1}));
};

inline constexpr auto encode_hash256 = [](
    auto& w, std::span<std::byte, 32> const& v) {
  w.write(v);
};
```

The size encoding is defined in terms of an exact bit-level specification, not
platform-dependent numeric limits.

```cpp
inline constexpr auto encode_size = [](auto& w, std::size_t v) {
  if (v < 253) {
    encode_u8(w, static_cast<std::uint8_t>(v));
  }
  else if (v <= 0xFFFF) {
    encode_u8(w, 253);
    encode_u16(w, static_cast<std::uint16_t>(v));
  }
  else if (v <= 0xFFFF'FFFF) {
    encode_u8(w, 254);
    encode_u32(w, static_cast<std::uint32_t>(v));
  }
  else {
    encode_u8(w, 255);
    encode_u64(w, static_cast<std::uint64_t>(v));
  }
};
```

Encoders compose explicitly. There is no overload resolution involved in
selecting how values are written.

```cpp
inline constexpr auto encode_bytes = [](
    auto& w, std::span<const std::byte> bytes) {
  encode_size(w, bytes.size());
  w.write(bytes);
};
```

Range encoding is parameterised over both the range and the element encoder:

```cpp
inline constexpr auto encode_range = [](
    auto& w, auto const& range, auto encode_elem) {
  encode_size(w, std::ranges::size(range));
  for (auto const& elem : range) {
    encode_elem(w, elem);
  }
};
```

With these primitives, higher-level encoders become straightforward and fully
explicit. Because encoders are not member functions, they are not implicitly
tied to the types they operate on, and they do not get pulled in as part of a
class's interface. Instead, they can be defined, included, and composed exactly
where they are needed, without coupling serialization logic to the structure of
the underlying data types.

```cpp
inline constexpr auto encode_outpoint = [](
    auto& w, COutPoint const& outpoint) {
  encode_hash256(w, outpoint.hash);
  encode_u32(w, outpoint.n);
};

inline constexpr auto encode_txin = [](
    auto& w, CTxIn const& txin) {
  encode_outpoint(w, txin.prevout);
  encode_bytes(w, as_bytes(txin.scriptSig));
  encode_u32(w, txin.nSequence);
};

inline constexpr auto encode_txout = [](
    auto& w, CTxOut const& txout) {
  encode_u64(w, txout.nValue);
  encode_bytes(w, as_bytes(txout.scriptPubKey));
};
```

Transaction encoding is itself a value parameterised by witness handling policy.

```cpp
enum class witness { disallow, allow };

inline constexpr auto encode_tx = [](witness wmode) {
  return [=](auto& w, CTransaction const& tx) {
    bool const with_witness =
      (wmode == witness::allow) && tx.HasWitness();

    encode_u32(w, tx.version);

    if (with_witness) {
      encode_u8(w, 0);
      encode_u8(w, 1);
    }

    encode_range(w, tx.vin, encode_txin);
    encode_range(w, tx.vout, encode_txout);

    if (with_witness) {
      for (auto const& in : tx.vin) {
        encode_range(w, in.scriptWitness.stack, encode_bytes);
      }
    }

    encode_u32(w, tx.nLockTime);
  };
};
```

There is no need for temporary "dummy" values such as `std::vector<CTxIn>` whose
only purpose is to trigger a particular overload of `operator<<`. Every byte
written is the result of an explicit encoder invocation.

```cpp
inline constexpr auto encode_block = [](witness wmode) {
  return [=](auto& w, CBlock const& block) {
    encode_block_header(w, block);
    encode_range(w, block.vtx, encode_tx(wmode));
  };
};
```

And that is sufficient to serialize a block. All output streams from `streams.h`
can be used as `Writer`, since they already provide the required
`write(std::span<const std::byte>)` member function. The existing `operator<<`
based serialization machinery is therefore not required in this model and does
not participate in the encoding path.

The remaining question is where the encoders should live. Since they are defined
as inline function objects, placing them in public headers provides little
benefit while still exposing the entire encoding layer to every translation
unit. What is needed instead is an abstraction that allows encoders to be hidden
behind a clear compilation boundary.

To achieve this, `writer_ref` is introduced: a type-erased wrapper that models
`Writer` and can be constructed from any concrete writer implementation:

```cpp
class writer_ref
{
public:
  template <Writer W>
    requires (!std::same_as<std::remove_cvref_t<W>, writer_ref>)
  writer_ref(W& object)
    : ptr{std::addressof(object)}
    , fun([](void* p, std::span<std::byte const> bytes) {
        static_cast<W*>(p)->write(bytes);
      })
  {}

  void write(std::span<std::byte const> bytes)
  {
    fun(ptr, bytes);
  }

private:
  void* ptr;
  void (*fun)(void*, std::span<std::byte const>);
};
```

Now only the `Writer` concept and the `writer_ref` abstraction need to be part
of the public interface. The actual encoding utilities, as well as all low-level
encoders, can be moved entirely into the implementation boundary.

Only the top-level serialization entry points for blocks and transactions are
exposed in a public header, while their definitions live in a private source
file. This ensures that the encoding layer is not part of the public API surface
at all, but remains an implementation detail.

```cpp
void serialize(CBlock const& tx, writer_ref writer);
void serialize(CTransaction const& tx, writer_ref writer);
```

There is just one small remaining issue. Using `writer_ref` directly in the
implementation means that every `write` call goes through a function pointer
indirection. While this preserves the abstraction boundary, it introduces
avoidable overhead at the lowest level of the encoding path.

This is where buffering becomes useful:

```cpp
void serialize(CBlock const& block, writer_ref writer)
{
  auto encode = encode_block(witness::allow);
  auto w = BufferedWriter<writer_ref>{writer};
  encode(w, block);
}
```

And this is really it. Next topic is **Deserialization**. Stay tuned.
