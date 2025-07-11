---
title: Refactoring CTest
---

Previously, I wrote about the four different ways of configuring a dashboard
client script with CTest:

1. [CTest Command-Line](https://cmake.org/cmake/help/v3.30/manual/ctest.1.html#dashboard-client-via-ctest-command-line)
2. Declarative CTest Script (undocumented)
3. [CTest Module](https://cmake.org/cmake/help/v3.30/module/CTest.html)
4. [CTest Script](https://cmake.org/cmake/help/v3.30/manual/ctest.1.html#dashboard-client-via-ctest-script)

I also mentioned that 4 is the most flexible approach because it can both
initialize *and* update the source directory. And that it is the only approach
that allows you to execute the same step more than once. This is the approach
that newcomers should be directed to.

Since it is the most flexible approach, you would assume that it is the core
implementation and the other three are legacy wrappers? Unfortunately no. The
core implementation is the one with the options named in CamelCase. When a CTest
command is executed, all relevant variables are copied into a central dictionary
in the `cmCTest` class, as if they had been parsed from a `.tcl` file. This
implementation detail is leaked in the `--extra-verbose` output of CTest:

```
SetCTestConfigurationFromCMakeVariable:UseLaunchers:CTEST_USE_LAUNCHERS
```

But that approach is not only at the core of the implementation, but also at the
core of the documentation. Look at the documentation of the
[`CTEST_USE_LAUNCHERS`](https://cmake.org/cmake/help/v3.30/variable/CTEST_USE_LAUNCHERS.html)
variable:

> Specify the CTest `UseLaunchers` setting in a `ctest(1)` dashboard client
> script.

There is more documentation about this setting under
[CTest Build Step](https://cmake.org/cmake/help/latest/manual/ctest.1.html#ctest-build-step),
but that is not even linked in the documentation about the `CTEST_USE_LAUNCHERS`
variable.

***

I am convinced that it is both possible and desirable to refactor CTest so that
the script mode really is at the core of the implementation. I will first
summarize the necessary refactoring steps and then highlight the benefits.

Let me start with the CTest Module, more specifically `CTestTargets.cmake`:

This module currently configures the file
`${CMAKE_ROOT}/Modules/DartConfiguration.tcl.in` to
`${PROJECT_BINARY_DIR}/DartConfiguration.tcl` and then creates a bunch of custom
targets that invoke `ctest -D` in the build directory.

First, I port the function `cmCTest::ProcessSteps()` from C++ to a CTest Script.
For now, I ignore the `GetRemainingTimeAllowed` checks, as the
`CTEST_TIME_LIMIT` variable is not set by the CTest module. I store the script
template as `Templates/CTestScript.cmake.in`, a file that was just
[recently removed](https://gitlab.kitware.com/cmake/cmake/-/commit/4a259d82ad5ff60451273f8275527653a8844ed9).

Next, I extend `CTestTargets.cmake`, so that it configures the file
`${CMAKE_ROOT}/Templates/CTestScript.cmake.in` to
`${PROJECT_BINARY_DIR}/CTestScript.cmake`. I also change the custom targets so
that they execute `ctest -S CTestScript.cmake` instead.

Result: CTest Module mode no longer depends on parsing `DartConfiguration.tcl`;
mission accomplished.

***

Declarative CTest Script mode can safely be removed, I am quite sure. Remember
that this is the mode where you invoke `ctest -S` with a script that calls none
of the `ctest_*` commands, neither directly nor indirectly. This mode is not
documented and the only test that covered it has been "temporarily disabled" for
the last
[fifteen years](https://gitlab.kitware.com/cmake/cmake/-/commit/0429853f1bbb9ec09452a0d2aa0d62cb631d0d11).

Removing it involves removing the code around `CTEST_RUN_CURRENT_SCRIPT`,
`cmCTestScriptHandler::SetRunCurrentScript`,
`cmCTestScriptHandler::RunCurrentScript`, but also
`cmCTestScriptHandler::RunConfigurationDashboard`. It is quite possible that a
lot of dead code can be removed as it is no longer accessible after removing
those functions.

***

Next is reimplementing a legacy wrapper for the options `-D`, `-M`, and `-T`.
This implementation should

1. parse the `DartConfiguration.tcl` file,
2. map the parsed settings to their corresponding CTest module variables,
3. produce a temporary `CTestScript.cmake` by configuring
   `${CMAKE_ROOT}/Templates/CTestScript.cmake.in`,
4. invoke the generated script with `ctest -S`.

***

What all this enables is a cleanup refactoring that may reduce the CTest
codebase by about 50%. How so?

At the moment there is a `cmCTest*Handler` instance for each build step owned by
the `cmCTest` class. But once CTest scripting mode is the core of the
implementation and the CTest command line mode is merely a legacy wrapper, the
only place where for example the `cmCTestConfigureHandler` is used is the
`cmCTestConfigureCommand`! The first cleanup will involve moving all the handler
instances from the `cmCTest` class to their corresponding command
implementations.

The second cleanup step will involve merging all the handler implementations
directly into their command implementations. It will be no longer necessary to
map "CMake variables" into "CTest configurations". Instead, the CMake variables
are used directly, which reduces the dependency to the `cmCTest` instance.

Once a `cmCTest*Command` is stateless and independent of `cmCTest`, its
implementation can be turned into a free function, like all the CMake commands
already are. Once that is done, the classes `cmCommand` and
`cmLegacyCommandWrapper` can finally be removed.

***

This cleanup greatly improves maintainability and extensibility of CTest
commands. One feature that is currently missing is the support of a
`CONFIGURATION` option in the `ctest_test` command. At the moment, you can use
`ctest_configure` to configure a project for a multi-config generator like
`Xcode` followed by multiple `ctest_build` commands that each build one
configuration. But you cannot use multiple `ctest_test` commands, as that
command has no `CONFIGURATION` option.

Adding support for this option before the cleanup will involve changes to
multiple files. After the cleanup it will be possible with only changing one
file.

It will also simplify adding new commands. One command that I would consider
useful is a `ctest_package` command, which invokes CPack in a way that CTest
knows how to submit the generated packages as build artefacts to a dashboard.
