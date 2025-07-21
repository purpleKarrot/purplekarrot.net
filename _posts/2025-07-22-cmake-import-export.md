---
title: CMake Import/Export
tags: [cmake]
---

In the following, I will try to address all your questions regarding
import/export with CMake. To aid in this task, I have set up four example
projects, which form a so-called *diamond of death* dependency graph:
<!--more--> [Foo](https://github.com/purpleKarrot/foo) depends on both
[Bar](https://github.com/purpleKarrot/bar) and
[Baz](https://github.com/purpleKarrot/baz), which both depend on different
versions of [Qux](https://github.com/purpleKarrot/qux). As I walk you through
the examples, you may want to have a look at the complete code on GitHub and
also make sure to check out the build artifacts of the releases.

## The importance of leak-free injection

There are several guidelines for writing good CMake code, which you may or may
not agree with. However, there are two rules that you *must* follow if you want
to allow customers to use your CMake project as a dependency:

1. Don't leak
2. Support injection

Always keep in mind that your project could be used as a sub-project of
something bigger. As a project author, it is your responsibility to make sure
that settings of your project do not affect the super-project (or sibling
projects). Project settings that have upstream effects are called leaks.

Project settings that have downstream effects are not leaks, but injection
points. This is an important distinction. Injection should not be prevented, but
must be supported.

The example projects follow those guidelines, so even the aforementioned
*diamond of death* dependencies do not cause any problems. Let's walk through
the code.

## Build libraries as `STATIC`, `SHARED`, or both?

There may be *technical reasons* for building a library as a `STATIC` library.
For example, a testing framework that provides the `main` function as part of
the library. There may also be *political reasons* for building a library as a
`SHARED` library. The most typical case is when a library uses the
[LGPL](https://www.gnu.org/licenses/lgpl-3.0.html), and a non-libre application
must allow its users to use their own version of the library without releasing
the application's build pipeline.

If none of these cases apply to your library, should both a `STATIC` and a
`SHARED` library be built at the same time? The difference between `STATIC` and
`SHARED` is not only that object files are linked differently; they also have to
be compiled differently. Since your clients will want to use only one variant of
your library while integrating it into their build pipeline, building both at
the same time could result in needless complexity. The better approach is to
support both, while leaving the final decision to the customer.

```cmake
if(Qux_IS_TOP_LEVEL)
  option(BUILD_SHARED_LIBS "Build using shared libraries" ON)
endif()

add_library(qux)
```

In the Qux project, neither `STATIC` nor `SHARED` is passed to `add_library()`,
which means that the library will be static or shared depending on the value of
the `BUILD_SHARED_LIBS` variable.

The
[documentation](https://cmake.org/cmake/help/latest/variable/BUILD_SHARED_LIBS.html)
of that variable briefly mentions the risk of leaking it: If a super-project has
two sub-projects and the second sub-project sets `BUILD_SHARED_LIBS` in the
cache, the first project may see different values of the variable between the
first and all following runs of CMake. The guideline that such a case can be
avoided by setting the cache variable in the top-level project should be
understood as a workaround. The root cause of the problem can be fixed by simply
not leaking the cache variable upstream. In the Qux project, the variable is set
in the cache only when it is guaranteed that no higher-level project exists.

## Symbol visibility

On Windows, all symbols that are defined in a shared library have to be
annotated in their declaration. When *building* the library, the symbols have to
be *exported*, so they need to be declared as `__declspec(dllexport)`. Likewise,
when *using* the library, the symbols have to be *imported*, so they need to be
declared as `__declspec(dllimport)`. When the library is built as a static
library, it is important that the symbols are *not* annotated. Multiple
definitions of the same symbol in different libraries can cause significant
issues.

On platforms other than Windows, all symbols are publicly visible by default.
When porting code to Windows, similar behavior can be enabled with the
[`WINDOWS_EXPORT_ALL_SYMBOLS`](https://cmake.org/cmake/help/latest/prop_tgt/WINDOWS_EXPORT_ALL_SYMBOLS.html)
property. Projects that are designed to be portable should instead adopt the
Windows approach, because it substantially improves load times, aids the
optimizer, reduces library size, and avoids symbol collision, as mentioned on
the [GCC Wiki](https://gcc.gnu.org/wiki/Visibility).

In order to allow the same header file to be used both for *building* and
*using* (1) a *portable* library (2) that could be *static* or *shared* (3), we
need *three dimensions* of conditional preprocessor definitions. To avoid a
deeply nested maze of conditions, the Qux library first separates the
portability dimension:

```c
#if defined(__ELF__) || defined(__MACH__) || defined(__WASM__)
#  define QUX_IMPORT __attribute__((visibility("default")))
#  define QUX_EXPORT __attribute__((visibility("default")))
#else  // assume PE/COFF
#  define QUX_IMPORT __declspec(dllimport)
#  define QUX_EXPORT __declspec(dllexport)
#endif
```

It does not base the condition on `__GNUC__`, because it regards the necessary
declaration as a property of the platform rather than a capability of the
compiler. Based on that abstraction, and the fact that no distinction is needed
between import and export in the case of static libraries, `QUX_API` is then
defined as follows:

```c
#if defined(qux_STATIC)
#  define QUX_API
#elif defined(qux_EXPORTS)
#  define QUX_API QUX_EXPORT
#else
#  define QUX_API QUX_IMPORT
#endif
```

CMake uses a define symbol when compiling sources for a shared library. The name
of that symbol can be set through the
[`DEFINE_SYMBOL`](https://cmake.org/cmake/help/latest/prop_tgt/DEFINE_SYMBOL.html)
target property. Qux uses the default value of `<target>_EXPORTS`.

When Qux is built as a static library, `qux_STATIC` needs to be defined both for
building and for using the library. This is achieved with a `PUBLIC` compile
definition:

```cmake
get_target_property(qux_type qux TYPE)
if(qux_type STREQUAL "STATIC_LIBRARY")
  target_compile_definitions(qux PUBLIC qux_STATIC foo)
endif()
```

Note that Qux does *not* use a generator expression, but classic conditional
CMake logic. The reason is that such a generator expression would be evaluated
in the context of the consumer, which is error-prone. Also, exporting CMake
generator expressions is not future-proof, as it is not possible to export them
with
[`install(PACKAGE_INFO)`](https://cmake.org/cmake/help/latest/command/install.html#package-info).

Finally, the
[`VISIBILITY_PRESET`](https://cmake.org/cmake/help/latest/prop_tgt/LANG_VISIBILITY_PRESET.html)
is set to `hidden`.

## Decoupling the linking interface from the runtime interface

On Windows, building a shared library produces two files: The dynamic link
library with the file extension `.dll`, and the import library with the file
extension `.lib` (or `.dll.a`). The import library is needed for the development
of a client application or library, and the dynamic link library is needed only
at runtime. This allows replacing the dynamic link library with a compatible
version without relinking the client application or library.

On other platforms, the default is that the client applications and libraries
are built against the same library file that is also used at runtime. This file
has the extension `.dylib` on Darwin and `.so` on Linux.

To get consistent behavior on all platforms, Qux sets the following target
properties:

```cmake
set_target_properties(qux PROPERTIES
  VERSION ${Qux_VERSION}
  SOVERSION ${Qux_VERSION_MAJOR}
  DLL_NAME_WITH_SOVERSION ON
  )
```

That means: On all platforms, client applications and libraries will build
against a file that does not have any version in the name (`qux.lib`,
`libqux.dylib`, `libqux.so`), while at runtime, a file with the major version in
the name will be used (`qux-1.dll`, `libqux.1.dylib`, `libqux.so.1`). This will
allow multiple major versions of the same library to be used at the same time by
different applications.

## Component based installation

Qux has this rather extensive `install` command invocation:

```cmake
install(TARGETS qux EXPORT qux-targets
  ARCHIVE
    COMPONENT develop
  LIBRARY
    CONFIGURATIONS Debug
    COMPONENT develop
  LIBRARY
    CONFIGURATIONS Release
    COMPONENT runtime
    NAMELINK_COMPONENT develop
  RUNTIME
    CONFIGURATIONS Debug
    COMPONENT develop
  RUNTIME
    CONFIGURATIONS Release
    COMPONENT runtime
  FILE_SET HEADERS
    COMPONENT develop
  )
```

While it does not set the `DESTINATION` for any artifact (support injection!),
it groups artifacts into components. Read the function call as follows:

```
for the target with name "qux", install
  the ARCHIVE artifacts (static libraries and Windows import libraries)
    (to the default location)
    and add them to the "develop" component
  the LIBRARY artifacts (.dylib and .so files)
    in the Debug configuration
    (to the default location)
    and add them to the "develop" component
  the LIBRARY artifacts
    in the Release configuration
    (to the default location)
    and add them to the "runtime" component
    except for the namelink artifacts, which belong to the "develop" component
  the RUNTIME artifacts (executables and .dll files)
    in the Debug configuration
    (to the default location)
    and add them to the "develop" component
  the RUNTIME artifacts
    in the Release configuration
    (to the default location)
    and add them to the "runtime" component
  the public header files
    (to the default location)
    and add them to the "develop" component
remember all this information so that I can later refer to it with the name "qux-targets"
```

All the information that is recorded in `qux-targets` is then exported with
`install(EXPORT)`, to a file named `qux-config.cmake`, which is installed
together with a `qux-config-version.cmake`, also as part of the "develop"
component.

In summary, the "develop" component contains everything that is needed to
develop an application or another library against Qux: Header files, static
libraries, import libraries, soname links, CMake package configuration files,
and debug builds of the libraries. The "runtime" component (which is a
dependency of the "develop" component), contains all the files that you would
need to ship alongside your application.

On the [Releases](https://github.com/purpleKarrot/qux/releases) page, you can
download the "runtime" and "develop" packages for different platforms and see
what is inside.

## Reprise: leak-free injection

Note that Qux does not set *any* value that begins with `CMAKE_`. Those
variables are not meant to be set by projects. Setting them as cache variables
would leak *into* the parent project, while setting them as non-cache variables
would prevent injection *from* the parent project or from the packager.

You want to know how you can set the language standard of your project when you
are not allowed to set `CMAKE_C_STANDARD`? Well, you can set `C_STANDARD` as a
target property! Most likely, your library does not impose the same language
standard to its clients that it uses internally. Consider a C++ library that
requires C++23 internally, but it has a C API, so C++23 is not a usage
requirement. But then you also provide a header-only abstraction on top of that
C API which requires at least C++20. And you want to export that information
through a package configuration. You see, a project wide setting for the
language standard does not satisfy your requirements anyway.

You want to make sure that your library is always built with certain compile
flags, installed to a certain location, or named differently depending on the
configuration? No. Just no. Those things are not your business as a project
author; they are the responsibility of the packager. Sure, you may want to make
sure that the binaries that you ship to have those kinds of tweaks, but then you
are in the role of a packager and not in the role of the project author.

Qux shows how those two roles can be separated. The packages that are provided
on the release page are built with those settings:

```yaml
run: >
  cmake -B build -G "Ninja Multi-Config"
  -DCMAKE_DEBUG_POSTFIX:STRING=d
  -DCMAKE_GNUtoMS:BOOL=ON
  -DCPACK_ARCHIVE_COMPONENT_INSTALL:BOOL=ON
```

Note that the packages include both Debug and Release configurations within a
single package. Additionally, the Windows build provides import libraries for
both GNU (`.dll.a`) and MSVC (`.lib`), enabling users to select the toolchain or
compiler that best suits their workflow and environment.

## Symbol visibility alternative: GenerateExportHeader

CMake provides an alternative to the logic that Qux uses to define `QUX_API`:
[GenerateExportHeader](https://cmake.org/cmake/help/latest/module/GenerateExportHeader.html)
is a module that can generate the necessary macros for annotating public
symbols. See the [source code](https://github.com/purpleKarrot/bar) and the
[releases](https://github.com/purpleKarrot/bar/releases) of Bar for an example
of how to use it and what the result looks like. Personally, I don't prefer this
approach, but I mention it here for completeness.

## Import/export of CMake package configuration

Look at how the Qux package is imported and used in Bar:

```cmake
add_library(bar)

find_package(Qux 1.0 REQUIRED)
target_link_libraries(bar PRIVATE Qux::qux)
```

That is all you need to write in your CMake configuration. However, much more
happens automatically behind the scenes. The directory containing the Qux
headers is added as an include directory to Bar. If Qux was built as a static
library, `qux_STATIC` is added as a compile definition. The linking process also
matches build configurations: when building Bar in Debug mode, it will link
against the Debug build of Qux; for all other configurations, it will link
against the Release build, since the Qux package only provides these two
configurations.

Additionally, when considering project Foo, it's important to note that
information about necessary runtime dependencies -- such as which DLL files are
required -- is also propagated automatically.

All this information is exported with `install(EXPORT)` and imported with
`find_package()`. Bar, in turn, exports all relevant information for its
clients. Furthermore, if Bar is built as a static library, users of Bar will
need to link against Qux. While they do not need access to the include directory
of Qux (since Qux is a `PRIVATE` dependency of Bar), they do need to link
against it and have access to `qux.dll` at runtime.

While CMake handles all necessary requirements on the target level, its support
for package-level dependencies is still experimental.

So Bar uses this code:

```cmake
get_target_property(bar_type bar TYPE)
if(bar_type STREQUAL "STATIC_LIBRARY")
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/bar-config.cmake"
    "include(CMakeFindDependencyMacro)\n"
    "find_dependency(Qux ${Qux_VERSION})\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/bar-targets.cmake\")\n"
    )
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/bar-config.cmake"
    DESTINATION "${cmake_package_config_dir}"
    )
  set(bar_targets_file "bar-targets.cmake")
else()
  set(bar_targets_file "bar-config.cmake")
endif()

install(EXPORT bar-targets DESTINATION "${cmake_package_config_dir}"
  FILE "${bar_targets_file}"
  NAMESPACE Bar::
  )
```

In practice, if Bar is built as a static library, the package-level dependencies
are written to `bar-config.cmake`, which then includes the file generated by
`install(EXPORT)` for the target-level dependencies. Otherwise, if Bar is not
built as a static library, it lets `install(EXPORT)` write the target-level
dependencies to `bar-config.cmake` directly, as no package-level dependency is
required. Even though Bar only requires version 1.0 of Qux, the package will
depend on the actual version used during the build, which may be higher.

The CI build for Bar is configured to produce packages for both `STATIC` and
`SHARED` libraries. This is possible even though Bar does not provide an option
for `BUILD_SHARED_LIBS`. On Windows, Bar is built with both GCC and MSVC, even
though the Qux dependency is built exclusively with GCC. On Darwin, Bar is built
with GCC, while Qux is built with Clang; on Linux, Bar is built with Clang,
while Qux is built with GCC. This deliberate mismatch of compilers and
toolchains demonstrates ABI compatibility across different environments. You can
review all the generated packages on the release page and compare their
contents.

## Fetching Content

While Bar requires Qux to be installed prior to building,
[Baz](https://github.com/purpleKarrot/baz) fetches the Qux source directly from
its tarball:

```cmake
block()
  include(FetchContent)
  FetchContent_Declare(Qux
    URL      https://github.com/purpleKarrot/qux/archive/refs/tags/v1.0.0.tar.gz
    URL_HASH SHA256=9eef61ee3fa769887cd35c8e48484006d6808abc492a8baa34ed0a8b775edadf
    EXCLUDE_FROM_ALL
    )

  set(BUILD_SHARED_LIBS OFF)
  FetchContent_MakeAvailable(Qux)
endblock()
```

Notice that `BUILD_SHARED_LIBS` is set within a scoped block, ensuring its value
is in effect when `FetchContent_MakeAvailable()` internally calls
`add_subdirectory()` for Qux. This pattern demonstrates why it is essential to
prevent variable leaks and to support injection: it allows super-project authors
to configure their dependencies according to their own requirements, providing
flexibility and reliability in complex build scenarios.

## Target Namespaces

Compare how Qux is consumed in both Bar and Baz:

```cmake
target_link_libraries(bar PRIVATE Qux::qux)
target_link_libraries(baz PRIVATE Qux::qux)
```

There is an important distinction: When Qux is imported from a CMake package
configuration (as in Bar), the `Qux::` prefix is specified by the `NAMESPACE`
argument to `install(EXPORT)`. When Qux is built as a sub-project (as in Baz),
neither import nor export is involved, and `Qux::qux` directly refers to the
`ALIAS` target. It is the responsibility of project authors to define an alias
target that matches the name used in the package configuration, ensuring that
consuming projects can use both approaches interchangeably.

## Plugin Architecture

So far, we have seen how to export symbols from libraries, the role of import
libraries, and how usage requirements propagate when targets are linked against
libraries. The [Foo](https://github.com/purpleKarrot/foo) project, however,
upends these conventions by presenting an example of a plugin architecture.

There are three kinds of binaries. The most commonly used are shared libraries
and executables. Shared libraries typically export symbols and are linked to by
other targets. Executables, on the other hand, usually do not export symbols and
are not linked to by other targets. The third kind is the `MODULE` library: like
shared libraries, it exports symbols, but it is never linked to.

Module libraries are used for plugins that are loaded on demand at runtime with
`dlopen`. Typically, they export a single symbol, such as `<name>_init`, which
is called to initialize the plugin. Of course, a plugin may link to other
libraries. But what if the plugin needs to call a function that is defined in
the executable that loads it?

On platforms where the symbols of all loaded binaries share a single address
space (such as most Unix-like systems), the plugin can simply call the function
directly. On Windows, however, the executable must explicitly export the symbol
and provide an import library for plugins to link against. In this case, the
executable needs to provide an import library, and the module library must link
to the executable.

```cmake
set_target_properties(foo PROPERTIES
  ENABLE_EXPORTS ON
  )

function(foo_plugin target)
  add_library(${target} MODULE ${ARGN})
  target_link_libraries(${target} PRIVATE Foo::foo)
  set_target_properties(${target} PROPERTIES
    PREFIX ""
    SUFFIX ".foo"
    )
endfunction()
```

In CMake, setting the `ENABLE_EXPORTS` property on an executable target causes
an import library to be generated when the executable is built. This import
library can then be linked to by other targets. It is common for applications to
enforce their own naming conventions for plugin files, as Foo does with its
`foo_plugin` command. A real-world example of this approach is the
[`Python3_add_library`](https://cmake.org/cmake/help/latest/module/FindPython3.html#commands)
command.

## Runtime Dependencies

Loading a plugin that is linked to other libraries requires that all necessary
runtime components are available and can be found by the dynamic loader. On
Unix-like systems, the dynamic linker typically searches standard library paths,
those specified by environment variables such as `LD_LIBRARY_PATH` (Linux) or
`DYLD_LIBRARY_PATH` (macOS), and paths embedded in the binary via the `RPATH` or
`RUNPATH` attributes. Setting the RPATH during the build process allows
executables and plugins to locate their dependencies at runtime without relying
solely on global environment variables.

On Windows, however, the situation is more restrictive. The dynamic loader
searches for DLLs in specific locations, such as the directory containing the
executable, system directories, or those listed in the `PATH` environment
variable. If a required DLL is not found in these locations, plugin loading will
fail. As a result, Windows applications often need to ensure that all necessary
runtime components are distributed together and placed in accessible locations,
or that the system `PATH` is configured appropriately.

As previously mentioned, CMake propagates runtime dependencies as usage
requirements via target properties along the link dependency graph, making them
accessible through generator expressions.

```cmake
add_test(NAME foobar COMMAND Foo::foo $<TARGET_FILE:foobar>)
set_tests_properties(foobar PROPERTIES
  PASS_REGULAR_EXPRESSION "hello, world!"
  ENVIRONMENT "PATH=$<TARGET_RUNTIME_DLL_DIRS:foobar>"
  )
```

Foo uses the `$<TARGET_RUNTIME_DLL_DIRS>` generator expression to set the `PATH`
environment variable in its unit tests. In practice, `$<TARGET_RUNTIME_DLLS>`
can be used to copy all required DLL files into a single directory that is
distributed with the application.

## Dependency Provider

The Foo project depends on both Bar and Baz. In its `CMakeLists.txt` file, it
imports both using `find_package()`:

```cmake
find_package(Bar REQUIRED)
find_package(Baz REQUIRED)
```

However, it also offers an approach for building all its dependencies from
source, giving full control over the exact version used for each dependency. The
CI build is configured to use GCC and MSVC on Windows, GCC on Linux, and Clang
on Darwin, testing both with prebuilt packages and with all dependencies built
entirely from source.

## The Future

Exporting CMake package configurations is extremely powerful, enabling advanced
features such as transitive usage requirements, generator expressions, and
platform-specific logic -- capabilities that are not possible with simple `.pc`
files. However, because CMake package configuration files are written in a
Turing-complete scripting language, they can invoke external processes and
perform arbitrary computations, which introduces complexity and potential
security considerations compared to the declarative nature of `.pc` files.

CMake has experimental support for importing and exporting package
configurations in the
[Common Package Specification](https://cps-org.github.io/cps/) format. I may
integrate this into the four example projects to gain a better understanding of
its capabilities. A contribution like this would also be very welcome.

## Summary

In this article, I walked through practical examples of CMake's import/export
mechanisms, symbol visibility, and dependency management across platforms. We
explored how shared, executable, and module libraries behave, and how to handle
runtime dependencies and plugin architectures in real-world projects. If you
have open questions or want to discuss specific scenarios, feel free to reach
out -- I'm always happy to help!
