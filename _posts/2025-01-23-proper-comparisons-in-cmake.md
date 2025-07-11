---
title: Proper Comparisons in CMake
---

It really saddens me whenever I see code like this:

```cmake
if(${CMAKE_SYSTEM_NAME} STREQUAL Darwin)
  message("System is Darwin")
else()
  message("System is not Darwin")
endif()
```

Imagine you run this code on Windows and you get the output "System is Darwin".
How is this possible?

Let's have a look at the [documentation of the `if` command](https://cmake.org/cmake/help/latest/command/if.html):

> ```cmake
> if(<variable|string> STREQUAL <variable|string>)
> ```
>
> True if the given string or variable's value is lexicographically equal to the
> string or variable on the right.

Both operands are interpreted as a variable when it is defined and as a string
literal when it is not.  Depending on whether there is a variable with the name
`Darwin` defined, the second operand is evaluated to the value of that variable
or as the string literal `"Darwin"`.

The first operand is expanded explicitly by the `${}` syntax, so what the `if()`
command sees are the arguments `Windows STREQUAL Darwin` and it will treat the
first argument exaclty like the second one:  Depending on whether there is a
variable with the name `Windows` defined, the operand is evaluated to the value
of that variable or as the string literal `"Windows"`.

That means, with the following two variable definitions:

```cmake
set(Darwin 1)
set(Windows 1)
```

The code above actually compares the two values `1` and `1`.

### What about properly quoting both sides?

```cmake
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
  message("System is Darwin")
else()
  message("System is not Darwin")
endif()
```

Depending on what is set as the minimum required CMake version (and way too many
maintainers do not set this properly), this might still suffer from the exact
same problem.

### How to properly compare strings:

1. Make sure that [policy `CMP0054`](https://cmake.org/cmake/help/latest/policy/CMP0054.html)
   is set to `NEW`, for example by setting the minimum required CMake version to
   3.1 or higher.

2. When you want an argument to be interpreted as a string, always put it in
   quotes.

3. When you want an argument to be interpreted as a variable, don't explicitly
   expand it with `${}`.

The recommended style is:

```cmake
cmake_minimum_required(VERSION 3.10)
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  message("System is Darwin")
else()
  message("System is not Darwin")
endif()
```

Now test your own CMake files.  If you find a match for `if($`, then you most
likely have a bug.
