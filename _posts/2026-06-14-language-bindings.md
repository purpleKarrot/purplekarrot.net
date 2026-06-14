---
title: Language Bindings and ABI Stability
summary: My opinionated vision on language bindings and ABI stability
tags: [api, bitcoin]
---

In a
[previous post](https://purplekarrot.net/blog/bitcoin-validation-library.html),
I described a side-effect-free Bitcoin validation library centered on clean C++
vocabulary types (`block_header`, `transaction`, `coin`, etc.), together with
the `chain_view` and `coin_index` abstractions and an overload set of `verify()`
functions.

This post outlines my opinionated vision on language bindings and ABI stability.

## Primary API: Modern C++

The library will be implemented in C++ and will expose a modern C++ API as its
primary interface. This allows the API itself to use modern C++ language and
standard library features designed for composable interfaces.

In the rare cases where the API will need to evolve, changes will be made in a
backward-compatible manner (using inline namespaces), guaranteeing a stable ABI
**across releases**.

Due to the nature of C++, it cannot guarantee ABI stability **across different
toolchains**, compilers, or standard library implementations. ABI compatibility
is guaranteed only when all participating binaries are built with the same
toolchain.

The C++ API is the preferred interface for C++ applications and will remain the
primary focus of development.

## Stable C Wrapper

The library will also provide a thin C wrapper that offers a stable ABI **across
releases and toolchains** on all supported platforms.

The wrapper will be built directly on top of the C++ implementation and will use
opaque handles, explicit resource management functions, and callback-based
interfaces for the abstractions `chain_view` and `coin_index`.

Its purpose is to provide a stable binary interface for environments where C++
ABI compatibility cannot be assumed, like dynamic loading, distribution as a
shared library, and languages without native C++ extension support.

The C wrapper is intended as a compatibility layer rather than the primary
programming interface. It will expose the complete functionality of the library
while remaining intentionally minimal and mechanically close to the underlying
C++ API.

## Language Bindings

For languages that support native extensions written in C++ (e.g. Python, Ruby,
Node.js, Java, Lua), bindings will be maintained **in the same repository** as
the library.

These bindings will use the **primary C++ API** directly rather than the C
wrapper and will target a stable ABI where the language provides a mechanism for
it (e.g. [Python's Stable ABI](https://docs.python.org/3/c-api/stable.html)).

Their responsibilities include:

* Wrapping vocabulary types (e.g. `block_header`, `transaction`, `coin`)
* Mapping error conditions or exceptions
* Adapting to runtime constraints (e.g. event loops)
* Exposing idiomatic language features (ranges, slices, iterators, generators)

Using the native C++ API avoids unnecessary translation layers and allows
bindings to expose an interface that maps naturally onto the underlying
implementation.

Languages without native C++ extension support (e.g. Go, Rust, Swift) will
instead rely on the stable C wrapper via FFI. Such bindings will be maintained
in **separate repositories** allowing the project to remain focused on C++
tooling.

For languages that support both approaches (e.g. Python), native extensions
built directly against the C++ API will be strongly preferred over FFI to the C
wrapper. This avoids unnecessary indirection, enables more idiomatic bindings,
and allows the implementation to take full advantage of the expressive C++ API.

## Philosophy

The design deliberately separates three distinct concerns:

* A modern, expressive C++ interface for C++ users.
* A stable C ABI for interoperability and long-term binary compatibility.
* Thin, idiomatic language bindings that integrate naturally with their host
  language while staying close to the underlying implementation.

The C wrapper exists to solve ABI and FFI problems - not to become the lowest
common denominator for every consumer of the library. Where a language can
directly leverage the native C++ interface, it should do so. Where it cannot,
the C wrapper provides a stable and portable foundation.

This keeps the core implementation clean, avoids unnecessary abstraction layers,
and allows each language binding to provide an interface that feels natural
without compromising performance or maintainability.
