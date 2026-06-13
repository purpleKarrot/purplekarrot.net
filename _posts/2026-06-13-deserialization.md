---
title: Deserialization
summary: >-
  The natural counterpart to serialization.
tags: [api, bitcoin]
---

At first glance, deserialization appears to mirror serialization almost exactly.
A `Reader` concept naturally complements `Writer`, a type-erased `reader_ref`
serves the same purpose as `writer_ref`, decoder utilities compose in the same
way as encoding utilities, and only the top-level `parse_block` and
`parse_transaction` entry points need to be exposed as part of the public
interface.

And because `reader_ref` introduces an indirect function call on every read
operation, a buffered reader seems like the obvious counterpart to the buffered
writer used during serialization. But while a buffered writer accumulates bytes
locally and defers emission until a large enough chunk is ready, a buffered
reader must *eagerly acquire* bytes before any consumer requests them.

This requires a primitive that treats partial reads as normal. Bitcoin Core's
current reader implementations instead model reads as either fully satisfied or
failed *via exceptions*. That model works when every read is assumed to be exact
and immediately fatal on mismatch, but it is fundamentally incompatible with
buffering.

Aside: Invalid input is not exceptional. Serialization typically fails because
of I/O errors or resource exhaustion. Deserialization, on the other hand,
routinely operates on untrusted network input. Truncated or malformed byte
sequences are expected and should therefore not be modeled using exceptions.

```cpp
template <typename R>
concept Reader = requires(R& r, std::span<std::byte> out) {
  { r.read_some(out) } -> std::same_as<std::size_t>;
};
```

The contract is intentionally tiny:

* `read_some(out)` returns a value in `[0, out.size()]`
* returning fewer bytes than requested is normal
* returning `0` indicates end-of-stream

This primitive allows to be wrapped in a buffered reader:

```cpp
template <Reader R, std::size_t S>
class buffered_reader
{
public:
  std::size_t read_some(std::span<std::byte> out)
  {
    std::size_t total = 0;

    while (!out.empty()) {
      if (pos == size) {
        size = r.read_some(buffer);
        pos = 0;

        if (size == 0) {
          break;
        }
      }

      auto n = std::min(out.size(), size - pos);
      std::memcpy(out.data(), buffer.data() + pos, n);

      out = out.subspan(n);
      pos += n;
      total += n;
    }

    return total;
  }

private:
  R& r;

  std::array<std::byte, S> buffer;
  std::size_t pos = 0;
  std::size_t size = 0;
};
```

Decoders have different requirements. A decoder for `std::uint32_t` cannot do
anything useful with only three bytes. Partial reads are therefore handled by a
`decoder_context`, which presents an exact-read interface while maintaining a
failure state.

```cpp
template <Reader R>
class decoder_context
{
public:
  bool good() const
  {
    return !failed;
  }

  void fail()
  {
      failed = true;
  }

  void read(std::span<std::byte> out)
  {
    while (!out.empty() && good()) {
      auto n = r.read_some(out);
      if (n == 0) {
        fail();
        return;
      }

      out = out.subspan(n);
    }
  }

private:
  R& r;
  bool failed = false;
};
```

As with serialization, the primitive building blocks are callable objects.

```cpp
inline constexpr auto decode_u8 = [](auto& r, std::uint8_t& v) {
  r.read(as_writable_bytes(std::span{&v, 1}));
};

inline constexpr auto decode_u16 = [](auto& r, std::uint16_t& v) {
  r.read(as_writable_bytes(std::span{&v, 1}));
  v = little_endian_to_native(v);
};

inline constexpr auto decode_u32 = [](auto& r, std::uint32_t& v) {
  r.read(as_writable_bytes(std::span{&v, 1}));
  v = little_endian_to_native(v);
};

inline constexpr auto decode_u64 = [](auto& r, std::uint64_t& v) {
  r.read(as_writable_bytes(std::span{&v, 1}));
  v = little_endian_to_native(v);
};
```

The size decoder flags errors in the parser context rather than by throwing
exceptions.

```cpp
inline constexpr auto decode_size = [](auto& r, std::size_t& size) {
  std::uint8_t tag;
  decode_u8(r, tag);

  if (!r.good()) {
    return;
  }

  if (tag < 253) {
    size = tag;
    return;
  }

  if (tag == 253) {
    std::uint16_t x;
    decode_u16(r, x);

    if (x < 253) {
      r.fail();
      return;
    }

    size = x;
  }
  else if (tag == 254) {
    std::uint32_t x;
    decode_u32(r, x);

    if (x < 0x1'0000u) {
      r.fail();
      return;
    }

    size = x;
  }
  else {
    std::uint64_t x;
    decode_u64(r, x);

    if (x < 0x1'0000'0000ull) {
      r.fail();
      return;
    }

    size = x;
  }

  if (size > MAX_SIZE) {
    r.fail();
  }
};
```

Range decoding is almost the exact counterpart to `encode_range`. A notable
subtlety is avoiding speculative allocation based on attacker-controlled size
fields.

```cpp
inline constexpr auto decode_range = [](
  auto& r, auto& range, auto decode_elem)
{
  std::size_t size;
  decode_size(r, size);

  range.clear();
  while (range.size() < size && r.good()) {
    if (range.size() == range.capacity()) {
      constexpr auto batch = MAX_VECTOR_ALLOCATE /
        sizeof(std::ranges::range_value_t<decltype(range)>);
      range.reserve(std::min(size, range.size() + batch));
    }

    decode_elem(r, range.emplace_back());
  }

  if (!r.good()) {
    range.clear();
  }
};

inline constexpr auto decode_bytes = [](auto& r, auto& out) {
  auto size = std::size_t{};
  if (decode_size(r, size); !r.good()) {
    return;
  }

  auto buf = std::vector<std::byte>(size);
  if (r.read(buf); !r.good()) {
    return;
  }

  out = decltype(out){std::move(buf)};
};
```

With these utilities in place, higher-level decoders become little more than a
description of the wire format.

```cpp
inline constexpr auto decode_outpoint = [](auto& r, COutPoint& out) {
  decode_uint256(r, out.hash);
  decode_u32(r, out.n);
};

inline constexpr auto decode_txin = [](auto& r, CTxIn& in) {
  decode_outpoint(r, in.prevout);
  decode_bytes(r, in.scriptSig);
  decode_u32(r, in.nSequence);
};

inline constexpr auto decode_txout = [](auto& r, CTxOut& out) {
  decode_i64(r, out.nValue);
  decode_bytes(r, out.scriptPubKey);
};

inline constexpr auto decode_tx = [](witness wmode) {
  return [=](auto& r, CTransaction& tx) {
    decode_u32(r, tx.version);
    decode_range(r, tx.vin, decode_txin);
    if (!tx.vin.empty() || wmode != witness::allow) {
      decode_range(r, tx.vout, decode_txout);
    }
    else {
      auto flags = std::uint8_t{};
      decode_u8(r, flags);
      if (flags == 1) {
        decode_range(r, tx.vin, decode_txin);
        decode_range(r, tx.vout, decode_txout);
      }
      else if (flags == 0) {
        tx.vout.clear();
      }
      else {
        r.fail();
      }
      for (auto& in : tx.vin) {
        decode_range(r, in.scriptWitness.stack, decode_bytes);
      }
      if (!tx.HasWitness()) {
        r.fail();
      }
    }
    decode_u32(r, tx.nLockTime);
  };
};
```

Finally, the public interface simply constructs the required layers and returns
`std::nullopt` on failure:

```cpp
std::optional<CBlock> parse_block(reader_ref r)
{
  auto br = buffered_reader{r};
  auto ctx = decoder_context{br};
  auto decode = decode_block(witness::allow);

  auto block = CBlock{};
  if (decode(ctx, block); !ctx.good()) {
    return std::nullopt;
  }

  return block;
}
```

The entire framework fits on little more than a page. `Reader` transports bytes,
`buffered_reader` optimizes transport, `decoder_context` turns partial reads
into exact reads while tracking failure, and the `decode_*` function objects
remain tiny, stateless, and composable in exactly the same way as their
serialization counterparts.

With this framework, serialization and deserialization is decoupled from the
vocabulary types. The next topic will be about the `ToString` functions.
