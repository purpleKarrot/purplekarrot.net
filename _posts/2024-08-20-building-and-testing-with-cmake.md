---
title: Building and Testing with CMake
tags: [cmake, ctest]
---

There are too many ways to build and test a project with CMake. On the other
hand, there is too little knowledge out there about those ways. As a
consequence, people wrap the CMake invocation in custom scripts written in Bash,
Python, TypeScript, etc.

Just look at the Jenkins configuration in your company. Look at different
implementations of GitHub Actions/workflows for CMake. I bet what you will find
is a complete framework with custom abstractions of core utilities, version
control systems, the CMake command line, the actual build system, and more.

Looking at the commands that actually perform the steps for configuring,
building, and testing, it is very likely that you see these:

```bash
mkdir -p $build_dir
cd $build_dir
cmake -G Ninja $source_dir
ninja
ninja test
```

I assume you know that CMake can create the build directory and provides an
abstraction for invoking the actual build system. You should also know that the
`test` target essentially just runs `ctest`. So you could simplify and
generalize the above commands to these:

```bash
cmake -G Ninja -S $source_dir -B $build_dir
cmake --build $build_dir
ctest --test-dir $build_dir
```

But did you know that CTest already provides a command-line abstraction to
execute these three steps?

```bash
ctest --build-and-test $source_dir $build_dir \
  --build-generator Ninja --test-command ctest
```

Don't ask me why the above command stops after the build step when
`--test-command ctest` is omitted. After all, this mode is called "build **and
test**", so just executing `ctest` would be a sane default when no test command
is explicitly set by the user.

Anyway, there is more. CTest also provides abstractions for the version control
system, coverage analysis, and memory checking. But here be dragons. There are,
believe it or not, four different ways to configure CTest as a dashboard client:

1. [CTest Command-Line](https://cmake.org/cmake/help/v3.30/manual/ctest.1.html#dashboard-client-via-ctest-command-line)
2. Declarative CTest Script (undocumented)
3. [CTest Module](https://cmake.org/cmake/help/v3.30/module/CTest.html)
4. [CTest Script](https://cmake.org/cmake/help/v3.30/manual/ctest.1.html#dashboard-client-via-ctest-script)

In the first approach, the command-line flag `-D` or a combination of `-M` and
`-T` is used to control *which* steps to execute. The actual logic that is
executed for those steps is controlled through a configuration file called
`DartConfiguration.tcl`, which is read from the current working directory.

Note that the documentation claims that this approach works in an
already-generated build tree. This is not true in all cases. What is definitely
needed is that the source repository is already checked out. While the source
directory can be updated, it cannot be initialized with this approach. We will
get back to those details later. For now, copy the following content into a file
called `DartConfiguration.tcl`:

```tcl
SourceDirectory: Example
BuildDirectory: Example-build
UpdateCommand: git
ConfigureCommand: cmake -G Ninja -DCMAKE_C_FLAGS_INIT=--coverage ..
CoverageCommand:gcov
MemoryCheckCommand: valgrind
```

Make sure that `Example` is a directory next to the `DartConfiguration.tcl` file
and contains a local clone of a Git repository. Then execute the following:

```bash
ctest -M Experimental \
  -T Start \
  -T Update \
  -T Configure \
  -T Build \
  -T Test \
  -T Coverage \
  -T MemCheck
```

Observe in the output that CTest updates the repository to the latest revision,
configures the project, builds it, runs the tests, analyzes the coverage, and
finds some memory leaks.

***

In the second approach, the `DartConfiguration.tcl` file is replaced with a file
written in CMake syntax:

```bash
set(CTEST_SOURCE_DIRECTORY "/home/dpfeifer/Example")
set(CTEST_BINARY_DIRECTORY "/home/dpfeifer/Example-build")
set(CTEST_COMMAND "ctest")
set(CTEST_CMAKE_COMMAND "cmake")
set(CTEST_CVS_CHECKOUT "gh repo clone Example")
```

The name of the file does not really matter. I use the name `CTestScript.cmake`
and invoke CTest like this:

```bash
ctest --script CTestScript.cmake --verbose
```

Remember that, with the previous approach, it was impossible to initialize the
source directory? With this approach, it is possible via the
`CTEST_CVS_CHECKOUT` variable. Despite the name, this variable can be used to
check out a repository with any version control system, as shown in the example.
However, updating probably only works with CVS.

What is worse is that this approach basically just handles the `update`,
`configure`, and `test` steps. Yes, the project is not even built before running
the tests. I wonder if anyone finds this useful.

Why am I even mentioning this approach when it is so barely useful? Because it
can get in the way when you don't expect it. I will get back to that.

***

The third approach also allows setting variables in CMake syntax. Not in a
separate file, but in the top-level project's `CMakeLists.txt` file, right
before `include(CTest)`. This module internally calls `configure_file` to place
`DartConfiguration.tcl` into the build tree.

Now, it becomes clear why the documentation claims that `ctest` may be invoked
with command-line flags `-D`, `-M`, and `-T` in an already-generated build tree:
Because the CTest module places `DartConfiguration.tcl` there. It also becomes
clear under which circumstance it does *not* work as advertised: When the
project does not `include(CTest)`!

But when a project does `include(CTest)`, it will get several custom targets
like `ExperimentalCoverage` that will execute `ctest -D ExperimentalCoverage`.

***

The last approach uses the same file and command-line as the second one. The
difference is that the build-and-test logic is scripted with CTest commands:

```bash
cmake_minimum_required(VERSION 3.14)

set(CTEST_SOURCE_DIRECTORY "/home/dpfeifer/Example")
set(CTEST_BINARY_DIRECTORY "/home/dpfeifer/Example-build")
set(CTEST_CMAKE_GENERATOR "Ninja")
find_program(CTEST_GIT_COMMAND "git")
find_program(CTEST_COVERAGE_COMMAND "gcov")
find_program(CTEST_MEMORYCHECK_COMMAND "valgrind")

cmake_host_system_information(RESULT NPROC QUERY NUMBER_OF_LOGICAL_CORES)

if(NOT EXISTS ${CTEST_SOURCE_DIRECTORY})
  set(CTEST_CHECKOUT_COMMAND "gh repo clone Example")
endif()

ctest_start("Experimental")
ctest_update()
ctest_configure(OPTIONS -DCMAKE_C_FLAGS_INIT=--coverage)
ctest_build(PARALLEL_LEVEL ${NPROC})
ctest_test(PARALLEL_LEVEL ${NPROC})
ctest_coverage()
ctest_memcheck(PARALLEL_LEVEL ${NPROC})
```

This is the only approach that can both initialize *and* update the source
directory. It is also the only approach that allows you to execute the same step
more than once. Imagine you want to use a multi-config generator and then run
`ctest_build` for each configuration. It gives full control over the logic of
what steps to run under what conditions. Imagine you want to run the expensive
memory checking only when the build finishes without warnings, as the warnings
may already indicate memory issues. The possibilities are endless.

***

How does `ctest --script` distinguish between "CTest Script" mode and the
dreaded "Declarative CTest Script" mode?

At the beginning of the script, CTest implicitly sets the variable
[`CTEST_RUN_CURRENT_SCRIPT`](https://cmake.org/cmake/help/v3.30/variable/CTEST_RUN_CURRENT_SCRIPT.html)
to 1. Each of the `ctest_*` functions sets the variable to 0. When this variable
is still 1 at the end of the script, CTest assumes that none of the `ctest_*`
functions have been called. However, when the `ctest_*` functions are called
from inside a scoped block, there may be cases where the variable is unchanged.
In such cases, it is necessary to explicitly `set(CTEST_RUN_CURRENT_SCRIPT 0)`.

***

My recommendation to everyone who wants to set up a CI system for CMake projects
is to use a CTest Script. For an example GitHub Action built using a CTest
script, have a look at
[purpleKarrot/cmake-action](https://github.com/purpleKarrot/cmake-action).

The fact that there are so many different approaches to the same use case is an
issue in my opinion. Also, the user experience of the CTest scripts needs to be
improved. I have some ideas about how these issues can be addressed. I will
write about them in a follow-up.
