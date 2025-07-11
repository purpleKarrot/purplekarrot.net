---
title: Fun with clang-format
tags: [clang-format]
---

There are formatting options that are a matter of taste and there are formatting
options that severely affect readability and maintenance. <!--more--> Consider
this code:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(
    int arrrrrrrrrrrrrrrrrrrrrg1,
    int arrrrrrrrrrrrrrrrrrrrrg2,
    int arrrrrrrrrrrrrrrrrrrrrg3) :
    Foo(arrrrrrrrrrrrrrrrrrrrrg1),
    Bar(arrrrrrrrrrrrrrrrrrrrrg2) {
    Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void Fooooooooooooooooooooo::Baz(int arg) {
    switch (arg) {
    default: {
        break;
    }

    case 21:
        break;
    }
}
```

In the first example, it is hard to distinguish between the initializer list and
the function body. In the second function, it is hard to spot the end of the
switch statement.

But how does the formatting change if we run this through `clang-format` with
the built-in presets?

LLVM:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(int arrrrrrrrrrrrrrrrrrrrrg1,
                                               int arrrrrrrrrrrrrrrrrrrrrg2,
                                               int arrrrrrrrrrrrrrrrrrrrrg3)
    : Foo(arrrrrrrrrrrrrrrrrrrrrg1), Bar(arrrrrrrrrrrrrrrrrrrrrg2) {
  Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void Fooooooooooooooooooooo::Baz(int arg) {
  switch (arg) {
  default: {
    break;
  }

  case 21:
    break;
  }
}
```

GNU:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo (int arrrrrrrrrrrrrrrrrrrrrg1,
                                                int arrrrrrrrrrrrrrrrrrrrrg2,
                                                int arrrrrrrrrrrrrrrrrrrrrg3)
    : Foo (arrrrrrrrrrrrrrrrrrrrrg1), Bar (arrrrrrrrrrrrrrrrrrrrrg2)
{
  Baz (arrrrrrrrrrrrrrrrrrrrrg3);
}

void
Fooooooooooooooooooooo::Baz (int arg)
{
  switch (arg)
    {
    default:
      {
        break;
      }

    case 21:
      break;
    }
}
```

Google:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(int arrrrrrrrrrrrrrrrrrrrrg1,
                                               int arrrrrrrrrrrrrrrrrrrrrg2,
                                               int arrrrrrrrrrrrrrrrrrrrrg3)
    : Foo(arrrrrrrrrrrrrrrrrrrrrg1), Bar(arrrrrrrrrrrrrrrrrrrrrg2) {
  Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void Fooooooooooooooooooooo::Baz(int arg) {
  switch (arg) {
    default: {
      break;
    }

    case 21:
      break;
  }
}
```

Chromium:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(int arrrrrrrrrrrrrrrrrrrrrg1,
                                               int arrrrrrrrrrrrrrrrrrrrrg2,
                                               int arrrrrrrrrrrrrrrrrrrrrg3)
    : Foo(arrrrrrrrrrrrrrrrrrrrrg1), Bar(arrrrrrrrrrrrrrrrrrrrrg2) {
  Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void Fooooooooooooooooooooo::Baz(int arg) {
  switch (arg) {
    default: {
      break;
    }

    case 21:
      break;
  }
}
```

Microsoft:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(int arrrrrrrrrrrrrrrrrrrrrg1, int arrrrrrrrrrrrrrrrrrrrrg2,
                                               int arrrrrrrrrrrrrrrrrrrrrg3)
    : Foo(arrrrrrrrrrrrrrrrrrrrrg1), Bar(arrrrrrrrrrrrrrrrrrrrrg2)
{
    Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void Fooooooooooooooooooooo::Baz(int arg)
{
    switch (arg)
    {
    default: {
        break;
    }

    case 21:
        break;
    }
}
```

Mozilla:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(int arrrrrrrrrrrrrrrrrrrrrg1,
                                               int arrrrrrrrrrrrrrrrrrrrrg2,
                                               int arrrrrrrrrrrrrrrrrrrrrg3)
  : Foo(arrrrrrrrrrrrrrrrrrrrrg1)
  , Bar(arrrrrrrrrrrrrrrrrrrrrg2)
{
  Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void
Fooooooooooooooooooooo::Baz(int arg)
{
  switch (arg) {
    default: {
      break;
    }

    case 21:
      break;
  }
}
```

WebKit:

```cpp
Fooooooooooooooooooooo::Fooooooooooooooooooooo(
    int arrrrrrrrrrrrrrrrrrrrrg1,
    int arrrrrrrrrrrrrrrrrrrrrg2,
    int arrrrrrrrrrrrrrrrrrrrrg3)
    : Foo(arrrrrrrrrrrrrrrrrrrrrg1)
    , Bar(arrrrrrrrrrrrrrrrrrrrrg2)
{
    Baz(arrrrrrrrrrrrrrrrrrrrrg3);
}

void Fooooooooooooooooooooo::Baz(int arg)
{
    switch (arg) {
    default: {
        break;
    }

    case 21:
        break;
    }
}
```

Having the opening brace for functions on a separate line really helps finding
the beginning of the function body of a constructor. This is done well in the
presets for GNU, Microsoft, Mozilla, and WebKit.

Indenting the case statements of a switch statement is necessary when cases
introduce their own scope. This is done well in the presets for GNU, Google,
Chromium, and Mozilla.

Aligning function arguments on the opening parenthesis moves them out of the
attention area. Especially in the case of the preset for Mozilla, the function
header looks disconnected from the body of the function. Another problem is that
this alignment requires changing the indentation of the arguments in case the
function name is changed. Only the WebKit preset does a good job here, even
though it does not produce perfectly readable formatting either: It is still
hard to distinguish the function arguments from the initialier list.

I cannot recommend any of the builtin presets at the time of this writing.
