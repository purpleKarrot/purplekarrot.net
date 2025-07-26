---
title: Aiming for ₿OSS Level 100
tags: [Boost, CMake, Git, Bitcoin, "Open Source"]
---

As a student, I wanted to become a game programmer. I learned C++ with the goal
of writing a computer game. My vision was to create something like a
decentralized version of "Ultima Online."

I couldn't imagine making a living from a single computer game; I considered
game programming more of a hobby. Therefore, I didn't enroll in a game
programming curriculum, but chose electrical engineering instead.

In the book "Game Programming Gems", at the end of chapter 2, I read:

> There are several references listed at the end of this article. Do yourself a
> favor and immediately pick them up if you don't yet own them.

What followed was a list of quite expensive books that I couldn't afford at the
time. Only years later, while doing a study abroad semester in Sydney, was I
able to borrow them from the UTS library. While I enrolled mostly in courses
that I needed for my electrical engineering studies, I also enrolled in one
course that I knew would not be credited: Graphics Programming.

That course was mostly for students who had serious plans to pursue a career as
game developers or in animation film studios. The lecturer made it clear that
this is a highly competitive market and that there is only one way to succeed:

> Make yourself the best programmer out there.

One of the aforementioned books was "Effective C++," written by Scott Meyers.
The book contains a chapter on "Templates and Generic Programming" that briefly
touches on the topic of template metaprogramming. After some examples, it reads:

> If you think this is cooler than ice cream, you've got the makings of a
> template metaprogrammer. If the templates and specializations and recursive
> instantiations and enum hacks and the need to type things like
> `Factorial<n-1>::value` make your skin crawl, well, you're a pretty normal C++
> programmer.

Well, I knew I had to make myself the best C++ programmer out there in order to
succeed in my goal of making a game, so I studied "Modern C++ Design" by Andrei
Alexandrescu and "C++ Template Metaprogramming" by Dave Abrahams.

I also followed Scott Meyers' advice to "Familiarize yourself with Boost," and I
even used the Boost.Build build system for all my projects while passively
following the Boost developers mailing list. I migrated all my projects to CMake
when I read about "alt.boost":

> Boost.CMake (or alt.boost) is the Boost distribution that all the cool kids
> are using.

CMake at the time had tremendous shortcomings. The biggest one was the lack of
"usage requirements," a feature that was available in Boost.Build. The typical
workaround was to wrap the built-in CMake commands like `add_library` into a
custom `boost_add_library` function that did two things: write the library's
include directory to an external file, and read similar files from dependent
libraries. To work properly, CMake had to be run twice.

The Boost.CMake approach from 2010 was put on ice due to lack of maintenance,
and all `CMakeLists.txt` files were removed from Boost's repository. I, however,
had continued to evolve those functions and volunteered as a maintainer in early
2011\. You can read in the
[Mailing List Archive](https://lists.boost.org/archives/list/boost@lists.boost.org/thread/VJ7PBP3F3RR7BV6CDQBEEAF3LQAJ2BTR/#CQ7GR6ESLTS34ZQAPPPA3J5KZAWQQ27B)
that my proposal received a warm welcome, which felt really good.

Dave Abrahams and I developed a very close friendship. There was a period when
we were in daily contact over Skype. Together, we developed a tool to rewrite
the history of Boost's monolithic Subversion repository as multiple small Git
repositories. In 2012, at the first C++Now, I met Dave in person for the first
time, along with Beman Dawes, Eric Niebler, and Sean Parent. It felt like coming
home.

I no longer thought about making a computer game. My main focus shifted to
empowering programmers. I became more interested in build systems, version
control, and CI, as well as C++ programming techniques like compiler firewalls
and type erasure, to make builds faster and more robust, reduce rebuilds, and
produce smaller binaries.

It must have been around that time when I first heard about a project called
"Bitcoin," which uses a blockchain to store transactions. The technology sounded
interesting to me, and I had some thoughts about how it could be useful for
securing in-game trading and preventing cheating in a decentralized MMORPG. But
as I said, those ideas no longer had much relevance for me at the time.

At the company where I was working, Klaus Iglberger and I started teaching C++
courses to employees. The feedback we received was overwhelming. People told us
they had never attended a course with so much wisdom and passion.

I know this may all sound impressive and, in some sense, boastful. But the
careful reader may realize that I haven't said much about my professional life.
I don't know how else to put it, but I probably suck as an employee. I can't
remember ever succeeding in any task that was given to me. During the first
three years of my career, I was at six different companies. I felt miserable. I
had tremendous doubts about myself.

Contributing to open source is what gave me a sense of fulfillment. I suffered
through meetings during the day and contributed to open source at night. It was
exhausting, but I needed something to recharge me.

In the beginning, I mostly made refactoring changes to CMake, such as
introducing `include-what-you-use` and `clang-tidy`, and then fixing warnings.
Those two tools basically introduced me to the codebase and its architecture.
First, `include-what-you-use` explained all the file-level dependencies to me,
and `clang-tidy` later showed me interesting places in the code, like all
`typedef`s or all `for` loops. This is how I learned about features that weren't
even mentioned in the documentation.

Another great source of inspiration was Stephen Kelly. He is the one who
introduced "usage requirements" to CMake -- a very gifted engineer and overall a
great person. I don't know about his current whereabouts, and I truly miss him.
For a short period, our paths were parallel: he came to CMake from KDE, while I
came to CMake from Boost. In 2017, he gave the talk
[Embracing Modern CMake](https://steveire.wordpress.com/2017/11/05/embracing-modern-cmake/)
at ACCU in April, while I gave the talk
[Effective CMake](https://www.youtube.com/watch?v=bsXLMQ6WgIk) at C++Now in May.
He later joined Microsoft, while I joined Apple.

I'm not allowed to share details about the project at Apple; all I can say is
that it was a research project for autonomous systems. I had nothing to do with
AI or ML; I simply did what I found necessary:

- Replaced complicated CMake wrapper functions with CMake's built-in support for
  usage requirements.
- Replaced custom scripts for compiling CUDA code with CMake's built-in support
  for CUDA.
- Integrated `include-what-you-use` and `clang-tidy`.
- Identified build bottlenecks and code bloat.
- Taught C++ courses to employees.

The difference compared to other companies was that I didn't have to argue about
the importance of these things. In his own words, Steve Jobs once said:

> A lot of companies -- I know it sounds crazy -- but a lot of companies don't
> do that. They hire people to tell them what to do. We hired people to tell us
> what to do.

Around 2019, I started to get interested in political philosophy and economics.
I don't remember how the YouTube algorithm brought me there, but during my
commute, I enjoyed watching videos from Gunnar Kaiser, which at that time were
about literature and movie reviews. That interest intensified in the following
years. I read books by Ludwig von Mises and listened to the "Mises Karma"
podcast.

In that podcast -- I don't remember which episode -- the question, "Did you read
The Bitcoin Standard?" came up. I could not make any sense of that question. I
considered The Bitcoin Standard to be to Bitcoin what the C++ Standard is to
C++. Why would anyone who is not a developer want to read the Standard? The ISO
C++ page about [The Standard](https://isocpp.org/std/the-standard) clearly
states:

> The standard is not intended to teach how to use C++. Rather, it is an
> international treaty -- a formal, legal, and sometimes mind-numbingly detailed
> technical document intended primarily for people writing C++ compilers and
> standard library implementations.

I finally understood what The Bitcoin Standard was, and I read it too. I
recognized that many ideas were taken from Hans-Hermann Hoppe, whose work I was
already familiar with. I made my first Bitcoin trade in November 2021, exactly
at the all-time high, only to experience a 76% crash the following year. But
since I had read The Bitcoin Standard, I wasn't too bothered.

The first time I returned to California after the lockdown was in the fall of
2023\. Getting travel approved was no longer that easy. Until 2019, it was up to
me to decide when to visit. It was recommended to show up at least every three
months. In 2019, I flew to the US five times. But now it was hard to get
approval for even one visit per year. Things had changed. I was happy to see old
colleagues again, but some of their faces appeared strangely frozen and
lifeless. I felt like Momo (from Michael Ende's novel) when she comes back from
Master Secundus Minutus Hora after a year.

In February 2024, it was announced that the project had been terminated. Some of
my colleagues were concerned about their future, but I was fairly confident that
I would find a new role. I had several options. The simplest was for our entire
build team to stay together and transfer to a new organization as a whole. My
preferred option was to work on a compiler or join the Build System and Package
Ecosystem organization. This would allow me to empower not only programmers on
one team, but also programmers outside the company.

But one after another, those options popped like soap bubbles. I could not stay
in my old team because their new organization required on-site presence, and I
was not willing to relocate to California. The compiler team, even though all
development happens openly on GitHub and they have contributors from all over
the world and from other companies, requires that all Apple employees work from
at most three different offices, and I was not willing to relocate to London.

Other teams required office presence even in cases where I would be the only one
from that team in the office. So basically, I would need to commute to Zurich
just to dial into a Webex meeting overseas. Or worse, I would need to commute to
Zurich simply to badge in, and then leave on time so I could join the Webex
meeting from home in the evening. I was not willing to accept such nonsense.

The very last option I had was another project that needed help with their CMake
setup, and they even had some requirements that involved upstreaming changes to
CMake. That sounded interesting. They also mentioned that working remotely and
contributing to open source might actually be easier if I were a contractor.
That sounded even more interesting! With the prospect of rejoining Apple as a
contractor, I accepted the severance package and signed a mutual termination
agreement -- only to be notified afterwards that former employees cannot be
contracted for a year. I felt deceived.

But I was also ready for a more radical change, so I explored some
possibilities. A decentralized version of "Ultima Online"? A native mobile
wallet that adheres to the
[Bitcoin Design Guide](https://bitcoin.design/guide/daily-spending-wallet/) and
integrates [Cashu](https://cashu.space/)? A modern
[CDash](https://www.cdash.org/) alternative? I didn't have a business model in
mind for any of these, but I wanted to experiment a bit.

In December, I saw a [JOIN THE ₿OSS PROGRAM](https://learning.chaincode.com/)
link on [Saving Satoshi](https://savingsatoshi.com/) and decided to apply. There
was a prerequisite task: make a code change in Bitcoin Core such that a single
test fails. Neat! I'm well aware that too many projects don't isolate their unit
tests well, so making a single change often causes a whole range of tests to
fail. My approach was to use `gcov` to figure out which code is covered by which
test.

The program started with a very inspiring speech by Adam Jonas. It was not
recorded, and I regret that I didn't record it myself. It would be motivating to
rewatch from time to time. I was also impressed by the sheer number of
participants from the African continent. I realized that I know nothing about
the people there.

The program itself was very well organized. Participants were given weekly
assignments, which consisted of reading chapters from "Mastering Bitcoin" and
submitting code exercises that were automatically graded through GitHub Actions.
Office hours were offered as well, where people could get their questions
answered, provided they submitted them in advance. It was stated that if you
hadn't submitted a question, you shouldn't participate in office hours. I didn't
know what to ask, so I cannot say what kinds of things were discussed there.

I finished my assignments rather quickly -- usually one or two days after I
received them. The nice thing was that there was no strict timeline. People who
finished their assignments early were given the next task, but there was no
pressure put on students who did not finish their assignments on time; everyone
was encouraged to work at their own pace.

Adam Jonas approached me directly and introduced me to Hennadii Stepanov, Cory
Fields, and TheCharlatan. They were familiar with my previous work, mostly the
"Effective CMake" talk from 2017. It reminded me that I had some recognition
back then, but I had been relatively quiet since. With the submission deadline
for C++Now 2025 approaching, I decided it was time to return and submitted
[Effective CTest](https://schedule.cppnow.org/session/2025/effective-ctest/).

It was good to see Dave Abrahams again, and I also met Bill Hoffman and Vito
Gamberini, but unfortunately not Brad King. Vito said it is embarrassing that I
know so much about CMake, and yet Kitware is unable to offer me a job.

Adam Jonas approached me again and asked how much my ability to contribute to
Bitcoin Core depends on money. That is a tough question. On one hand, of course
I have expenses to cover, and I know very well that my knowledge is rare and how
much other companies have paid in the past. On the other hand, it's difficult to
argue for compensation when I'm not only giving this knowledge away for free,
but actually paying to do so. The flight and accommodation in Aspen were not
cheap, not to mention the time away from my family. While I'm happy to
contribute and invest in the community, I simply can't do this indefinitely at
my own expense.

When other people at C++Now told me their companies had open positions, I felt
my gut revolt. I just can't work at an arbitrary company with schedules and
stand-up meetings. I know that my true potential requires freedom of mind.

Adam Jonas introduced me to Mike Schmidt, who invited me to work at the Brink
office in London for two weeks. For this trip, my travel and accommodation
expenses were covered -- in Bitcoin, of course. This was the second Bitcoin
payment I ever received. The first was when I took first place in "Who Wants to
Be a Satoshi Millionaire."

The atmosphere in the Brink office reminded me of Apple in 2017: talented
engineers with self-motivation and focus. So much focus, in fact, that I
completely forgot to sign in to the IRC developer meetings. I actually expected
a bit more technical debate offline, given that people were already in the same
room.

Instead of a flat hierarchy, there is no hierarchy at all. I was also surprised
by the amount of trust I received. Basically, they invited a complete stranger
into their office -- someone who sometimes stayed late after everyone else was
gone.

Two weeks was perhaps a bit too long. I would prefer shorter, but more engaging
gatherings. I also prefer retreats in the mountains, by a lake, or in the forest
over crowded places. I am definitely looking forward to the Core Developers
meeting later this year.

I am a bit shocked by the code quality of Bitcoin Core, to be honest. Issues
such as public data members, `const` member functions returning pointers or
references to mutable data, pointers with implied ownership, naked `new` and
`delete`, raw loops, and raw synchronization primitives all indicate a lack of
knowledge about robust C++ design. Is this really supposed to be the foundation
for a monetary system intended to last for the next few hundred years?

Oh, I can see myself fitting in here very well. I would just do what I always
do:

- Reduce custom scripting logic by using built-in CMake functionality.
- Refactor code for maintainability and robustness.
- Share C++ knowledge about abstraction, ownership, and error safety.

I owe a huge thank you to Adam Jonas for helping me get off ₿OSS 0, to Mike
Schmidt for inviting me to visit Brink, to my wife and family for their support,
and even to Apple for making the mistake of letting me go. Now, I am aiming for
₿OSS level 100.
