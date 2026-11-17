---
title: Distributed Software Development with Nostr
summary: >-
  Combining Git, Nostr, and CTest connects decades-old engineering practices
  through an open protocol, letting developers, reviewers, and independent
  testers collaborate without depending on a centralized development platform.
tags: [cmake, ctest, git, nostr]
---

The idea of distributed software development predates Git and Nostr by several
years. As early as 1998, the Visualization Toolkit (VTK) employed distributed
build and testing infrastructure. The paper
[Visualization Toolkit Extreme Testing](https://www.researchgate.net/publication/255676738_Visualization_toolkit_extreme_testing),
published in 2001, describes how automated testing across different hardware and
operating systems became an integral part of its development process.

CTest, which ships with CMake, has traditionally distinguished among three testing
models: Experimental, Continuous, and Nightly. The
[CMake development workflow](https://gitlab.kitware.com/cmake/cmake/-/blob/master/Help/dev/review.rst)
builds upon these models to integrate contributions and test them across a wide
range of configurations before merging them into the main development branch.

In my talk [Effective CTest](https://youtu.be/whaPQ5BU2y8) at C++Now 2025, I
advocated for a separation of responsibilities between project maintainers and
build pipeline maintainers.

In
[Redistributing Git with Nostr](nostr:naddr1qvzqqqr4gupzqwlsccluhy6xxsr6l9a9uhhxf75g85g8a709tprjcn4e42h053vaqy2hwumn8ghj7cnpwdehq6tnw3hkctn0wfnj7qg6waehxw309ac8junpd45kgtnxd9shg6npvchxxmmd9uqqsvfcvenr2dp3xc4n5kfx),
[fiatjaf](nostr:npub180cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsyjh6w6)
discusses how Nostr can remove the network effect that drives open-source
projects towards centralized development platforms, despite Git itself being
distributed.

I want to bring these ideas together and describe a development workflow based
on Git, Nostr, and CTest.

## Separation of Responsibilities

A software project has several kinds of contributors:

- Authors implement features and fix defects.
- Reviewers evaluate proposed changes.
- Testers discover defects by building and testing the software under different
  conditions.
- Maintainers decide which contributions to integrate.

A person may assume several of these roles, but each role represents a distinct
responsibility.

In particular, testers do not need to be members of the development team.
Someone who maintains build infrastructure for an unusual hardware architecture
contributes to the quality of a project without necessarily understanding its
implementation or ever modifying its source code.

Open-source software development should be as accessible to testers as it is to
authors.

## Repository Discovery

A project will be managed by an integration bot with its own Nostr identity.

The bot will publish a
[NIP-34](https://github.com/nostr-protocol/nips/blob/master/34.md) repository
announcement (kind 30617), containing the project's name, description, Git clone
URLs, maintainers, and preferred relays.

The repository announcement provides a stable identity for the project,
independent of where its Git repository is hosted. A project can change its
hosting provider or advertise additional mirrors without changing its identity.

The bot will also publish a NIP-34 repository state announcement (kind 30618),
identifying the current revision of the main development branch.

Developers, testers, and other services can discover projects through Nostr
without integrating with the APIs of individual Git hosting providers.

## Submitting a Contribution

A developer will clone the repository, create a topic branch, and commit their
changes using Git.

They will make their commits available through a Git server of their choice and
publish a NIP-34 pull request (kind 1618). The event will reference the target
repository, describe the proposed changes, and identify the Git commit and clone
URLs from which the contribution can be retrieved.

There is no need for the developer to have an account on the server hosting the
target repository.

When the developer wants to revise their contribution, they will publish a
NIP-34 pull request update (kind 1619), identifying the new revision.

Simply pushing changes to a Git branch will not update the pull request. The
revision under consideration is explicitly identified by a signed Nostr event.

## Review

Reviewers will discuss contributions using
[NIP-22](https://github.com/nostr-protocol/nips/blob/master/22.md) comments
(kind 1111) referencing the pull request.

Following the convention established by the CMake project, comments can contain
trailers to express the outcome of a review:

```
Reviewed-by: me
```

Other forms of acknowledgment include:

```
Acked-by: me
Tested-by: me
```

The bot will associate these acknowledgments with the public key of the person
signing the event.

When a contribution is revised, the previous acknowledgments will be discarded.
A review of one revision does not imply approval of another.

Applicable acknowledgments will eventually become part of the Git merge commit,
giving contributors credit for their work in the permanent history of the
project.

## Staging

Two contributions may work perfectly in isolation and still introduce a defect
when combined. One could address this problem by integrating one contribution at
a time, testing it thoroughly before proceeding with the next. However, this
approach does not scale.

If a project requires an overnight testing cycle for each contribution, it could
integrate at most one contribution per day. Increasing the number of
contributors or testing resources would not remove this bottleneck.

By integrating multiple contributions into a common staging branch, we can test
their interactions while sharing the cost of an extensive testing cycle across
many contributions. This decouples integration throughput from testing latency,
without requiring contributions to be merged into the main development branch as
a batch.

The workflow therefore introduces a staging ref:

```
refs/stage/master/head
```

The staging ref represents the current main development branch combined with
contributions selected for integration testing.

When a maintainer considers a contribution ready for integration testing, they
will publish a NIP-22 comment containing the following trailer:

```
Do: stage
```

The bot will attempt to integrate the contribution into the staging ref. It will
acknowledge the command with a
[NIP-25](https://github.com/nostr-protocol/nips/blob/master/25.md) reaction
(kind 7), using the robot emoji.

As additional contributions are staged, they will be integrated cumulatively.

For example, if three pull requests A, B, and C are staged, the staging history
will conceptually look like this:

```
master
  |
  +-- Merge A
       |
       +-- Merge B
            |
            +-- Merge C  <-- staging
```

None of these contributions has been merged into master yet.

If a contribution turns out to cause a problem, a maintainer or the author of
that contribution can request its removal:

```
Do: unstage
```

The bot will rebuild the staging history with the remaining contributions. If a
contribution can no longer be integrated because of conflicts, the bot will
remove it from staging and explain the reason in a comment.

Publishing a NIP-34 pull request update (kind 1619) will also unstage the
contribution. The revised contribution will have to be reviewed and explicitly
staged again.

This allows the project to maintain a stable main development branch while
continuously integrating proposed changes.

## Three Models of Testing

Testers will be able to participate in three complementary ways, corresponding
to the traditional CTest testing models.

### Experimental

A tester may subscribe to NIP-34 pull request announcements (kind 1618) and
updates (kind 1619) to automatically build and test individual contributions.

These builds will be submitted to the Experimental group of a testing dashboard.

CTest provides a variable,
[`CTEST_CHANGE_ID`](https://cmake.org/cmake/help/latest/variable/CTEST_CHANGE_ID.html),
for associating a build with an external change identifier. Setting this
variable to the event ID of the original pull request will allow the dashboard
to associate test results with the corresponding discussion on Nostr. The Git
revision recorded in the submission will identify what was actually tested.

Testers may choose to test every contribution, select contributions according to
their own criteria, or manually investigate a particular change.

Experimental builds provide feedback during review, before a contribution is
selected for integration testing.

### Continuous

A tester may set up a build that continuously monitors the staging ref:

```
refs/stage/master/head
```

Whenever the revision changes, the tester will build and test the new integrated
state and submit the results to the Continuous group.

Continuous builds should provide relatively quick feedback. They allow
maintainers to discover integration problems shortly after a contribution has
been staged.

As the staging ref can change several times a day, different Continuous builds
may test different revisions.

### Nightly

Once per day, the bot will take a snapshot of the staging ref and publish it
under two additional Git refs:

```
refs/stage/master/nightly/latest
refs/stage/master/nightly/YYYY/MM/DD
```

Testers will build this snapshot and submit their results to the Nightly group.

Unlike Continuous builds, Nightly builds are intended to test a common revision.
This allows testers across different time zones, using different hardware,
operating systems, compilers, and build configurations, to evaluate the same
integrated state.

Nightly builds can exercise configurations that are too expensive for Continuous
testing, such as sanitizers, extensive regression tests, code coverage analysis,
or performance benchmarks.

The dated refs also allow developers to revisit previous nightly revisions when
investigating regressions.

The three testing models answer different questions:

- Experimental: Does the proposed change work?
- Continuous: Do the proposed changes work together?
- Nightly: Does the integrated software work across all the configurations in
  which we intend to support it?

## Distributed Build Infrastructure

The integration bot will not schedule or execute any of these builds.

A tester may operate a single Raspberry Pi that performs one Nightly build of a
single project. Another tester may orchestrate hundreds of build jobs across a
fleet of machines, covering dozens of projects.

Both are equally valid participants in the workflow.

There is nothing wrong with centralized orchestration within a testing
organization. What we want to avoid is having a single instance responsible for
orchestrating the entire project's testing infrastructure.

Testers will decide which projects to test, which configurations to employ,
which resources to allocate, and how to schedule their builds. They can use
CTest scripts, cron jobs, Jenkins, GitHub Actions, or any other orchestration
mechanism they prefer.

Build pipelines can be developed independently of the software projects and
reused across multiple projects.

This also establishes an interesting relationship between project maintainers
and build pipeline maintainers. Project maintainers try to produce software that
works under all supported conditions. Build pipeline maintainers try to discover
conditions under which it does not.

Adding a new compiler, enabling additional warnings, employing a new static
analysis tool, or testing on a previously unsupported platform becomes a
contribution that does not require modifying the project itself.

## The Dashboard

Distributed testing infrastructure requires a common place to evaluate results.
It does not require a common place to execute builds.

A CDash-compatible dashboard centered around Nostr is currently under
construction at [ci.chorse.dev](https://ci.chorse.dev).

Adding a project to the dashboard will require a NIP-34 repository announcement
(kind 30617). Projects will therefore be identified by their Nostr repository
identity rather than an account on a particular Git hosting platform.

Testers will be able to authenticate their submissions using CTest's support for
[additional HTTP headers](https://cmake.org/cmake/help/latest/manual/ctest.1.html#cmdoption-ctest-dashboard-http-header).
Authenticated submissions will be attributed to the Nostr identities of their
owners.

There will be no need for a GitHub account, nor will there be a "Sign in with
GitHub" option.

The dashboard will collect structured information about configuration errors,
compiler diagnostics, test failures, coverage, and other measurements. Rather
than inspecting the terminal output of individual build jobs, developers will be
able to evaluate the quality of the software across independently operated
testing sites.

The dashboard is an observer of the development process. It does not control the
testing infrastructure or the integration of contributions.

## Merging

When a contribution has been sufficiently reviewed and tested, a lead maintainer
will authorize its integration by publishing a NIP-22 comment containing the
trailer:

```
Do: merge
```

The bot will merge the selected contribution into master, preserving its
original Git history and recording the applicable review acknowledgments and
references to the Nostr events in the merge commit.

It will then publish a NIP-34 Applied status event (kind 1631), followed by a
repository state announcement (kind 30618) identifying the new revision of
master.

The staging ref will be rebuilt on top of the updated master, retaining the
remaining staged contributions.

Only the bot will have permission to advance master and the integration refs.
Maintainers express their decisions through signed Nostr events rather than
directly pushing to the main development branch.

Importantly, the decision to merge remains with the lead maintainers.

The bot will not query the testing dashboard or enforce a predefined set of
required builds. A documentation change may not require nightly testing at all.
A substantial architectural change may require several days of testing.

Test results inform engineering decisions. They do not replace them.

## Outlook

Initially, the integration bot will recognize command trailers in NIP-22
comments, following the convention established by the CMake review workflow.
This allows the workflow to be implemented using existing Nostr clients without
requiring any protocol extensions.

In the future, a dedicated NIP could introduce structured events for expressing
integration commands and review acknowledgments. Clients could then provide
dedicated controls for these actions instead of requiring users to enter command
trailers in comments.

One capability currently missing from NIP-34 is the management of labels
throughout the lifetime of a pull request or issue.

The CMake project uses labels such as:

- `workflow:wip`
- `workflow:in-review`
- `workflow:nightly-testing`

When a contribution is staged, the bot should be able to replace its
`workflow:in-review` label with `workflow:nightly-testing`. When it is unstaged,
the bot should be able to reverse that transition.

NIP-34 allows labels to be included as `t` tags in the original pull request or
issue event. However, these events are immutable. There is no standardized
mechanism in NIP-34 for authorized maintainers to subsequently add, remove, or
replace these labels.

[NIP-32](https://github.com/nostr-protocol/nips/blob/master/32.md) provides a
mechanism for attaching labels to existing events, but does not define how
repository maintainers collectively manage a project's current set of labels.

Such a mechanism would allow clients to display and filter contributions
according to their current workflow state, without having to understand the
commands or interpret the behavior of a particular integration bot.

The workflow states themselves should not be defined by the protocol. Different
projects have different development processes. The protocol should merely
provide the means for projects to express and manage their own labels.

## Conclusion

The proposed workflow requires surprisingly little coordination between its
components.

Git provides the distributed version control system and the refs that identify
revisions for testing.

Nostr provides repository discovery, contribution management, discussion,
review, and integration commands.

The integration bot maintains the project's Git history according to decisions
made by its maintainers.

CTest provides a common mechanism for collecting and submitting structured build
and test results.

A Dashboard aggregates those results and makes them accessible to developers.

None of these components needs to assume responsibility for the others.

A developer can contribute without an account on the project's Git server. A
tester can contribute without being granted access to the project's development
infrastructure. A project can change its hosting provider without disrupting its
community.

The underlying engineering practices are decades old. Nostr gives us the
opportunity to connect them through an open protocol rather than a centralized
development platform.
