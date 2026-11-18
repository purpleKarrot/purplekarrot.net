---
title: Fine-grained Repository Permissions
summary: >-
  Repository ownership, branch access, and review responsibilities need separate
  permissions. A proposal for expressing and enforcing them across Nostr clients.
tags: [nostr, nip34]
---

In
[Distributed Software Development with Nostr](https://purplekarrot.net/blog/distributed-software-development-with-nostr.html),
I described a workflow built around Git, Nostr, and independently operated
testing infrastructure. Working on the integration bot for that workflow has
exposed several gaps: who owns the repository, who may change its state, and how
other applications recognize those changes.

Consider a company with three employees and an integration bot. Alice may
update `master`. Bob prepares staging refs and coordinates reviews. Carol may
revise pull requests and manage their lifecycle, but must not push to branches.
The bot carries out their authorized requests. Replacing any of them should
leave the company's repository identity intact.

## The problems

### Repository identity is tied to the announcing key

In my earlier design, the integration bot published the repository announcement.
That makes the bot's public key part of the repository's address. Replacing the
bot's key would therefore change the address that contributors use to identify
the project.

The company should own that identity. Employees and services need to work under
their own keys without receiving the company's ownership key. This also affects
repository-state announcements: under
[NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md),
each publisher's key is part of an addressable event's identity. An employee's
state event cannot simply replace the owner's event.

### A maintainer list cannot express separate responsibilities

[NIP-34](https://github.com/nostr-protocol/nips/blob/master/34.md) provides a
`maintainers` list, but our example needs distinct permissions. Bob needs access
to staging refs without access to `master`. Carol needs to manage contributions
without branch-write access. A single list does not express those boundaries.

PR updates expose the same question.
[Issue #2524](https://github.com/nostr-protocol/nips/issues/2524)
asks who may publish an update and proposes accepting the original author or a
maintainer. That addresses one event kind, but still leaves contribution
management bundled into the maintainer role.

These boundaries must also hold across applications. If Bob cannot push to
`master`, asking a bot to merge into `master` must not bypass that restriction.
A permission configured only inside one bot does not tell a Git host or another
client what Bob may do.

### Integration refs are missing from state announcements

The
[repository-state format in NIP-34](https://github.com/nostr-protocol/nips/blob/master/34.md#repository-state-announcements)
describes ref tags as `refs/<heads|tags>/<branch-or-tag-name>`. My workflow also
uses refs such as `refs/stage/master/head` and
`refs/stage/master/nightly/latest`.

There is no reason for the protocol to restrict announcements to branch and
tag refs. Removing that restriction would let projects advertise integration
refs too, giving testers more opportunities to discover work they could build.

### Projects need tags in separate dimensions

Open, Applied, Closed, and Draft describe a contribution's lifecycle. Projects
also need to classify contributions in ways that the protocol cannot enumerate.
A project might use a `workflow` dimension with values such as `under-review`
and `ready-to-merge`, a `priority` dimension with `low` and `high`, or a
`component` dimension with `api` and `documentation`.

These are independent dimensions: assigning `priority:high` should not replace
`workflow:under-review`. Projects also need to delegate authority separately.
Someone allowed to assign a component need not be allowed to change priority.

[Issue #2549](https://github.com/nostr-protocol/nips/issues/2549)
raises the workflow case. The underlying need is broader: repository-scoped
tags in project-defined dimensions, with permissions scoped to each dimension.

## The proposal

I propose extending NIP-34 with owner-signed permission grants, delegated state
announcements, support for integration refs, and scoped tags in project-defined
dimensions. The grants would authorize the same operations in Git hosts,
interactive clients, and automation. The syntax and rules below are proposed
extensions, not part of the existing standard. All JSON examples show event
tags, not complete signed events.

### Grant operations and scopes

The company would publish explicit grants in its repository announcement, a
kind `30617` event signed with the owner's key:

```json
[
  ["d", "widget"],
  ["permissions", "1"],
  ["permission", "<alice-pubkey>", "update-ref", "refs/heads/master"],
  ["permission", "<bob-pubkey>", "update-ref", "refs/stage/master/**"],
  ["permission", "<bob-pubkey>", "set-tag", "workflow"],
  ["permission", "<carol-pubkey>", "update-pr", "*"],
  ["permission", "<carol-pubkey>", "set-status", "lifecycle"],
  ["permission", "<automation-pubkey>", "*", "*"]
]
```

Each grant contains a public key, an operation, and a scope. Public keys use
lowercase hexadecimal encoding; the angle-bracketed values are placeholders.
Repeated grants are additive; there are no deny rules or inherited roles.

The initial vocabulary would be small:

- `update-ref` modifies and publishes state for refs matching its scope. The
  scope is an exact Git ref or a ref glob.
- `update-pr` publishes revisions of PRs belonging to the repository. Its scope
  is `*`.
- `set-status` changes the lifecycle status: Open, Applied, Closed, or Draft.
  Its scope is `lifecycle`.
- `set-tag` assigns or clears a tag in a project-defined dimension. Its scope is
  the dimension name, such as `workflow` or `priority`.
- `*` with scope `*` grants all operational permissions defined by this
  extension.

Ref globs would match the entire ref name. A single `*` matches zero or more
characters within one path component, but never `/`. A double `**` matches zero
or more characters including `/`. All other characters match literally.
For example, `refs/heads/*` matches `refs/heads/master` but not
`refs/heads/feature/login`; `refs/heads/**` matches both. Bob's
`refs/stage/master/**` scope covers staging refs at any depth. The scope for all
refs is `refs/**`.

Glob matching applies only to `update-ref` scopes. Other scopes match exactly;
the `*` operation with scope `*` remains the explicit grant of all operational
permissions. Unknown operations or unsupported permission versions must not be
interpreted as granting authority.

The announcement's owner controls the policy and has all repository permissions.
Even the wildcard grant does not authorize someone to replace the owner's
announcement or grant permissions to others. It authorizes repository work,
without sharing the ownership key.

"Maintainer" and "lead maintainer" could remain useful names for project-defined
bundles of these grants. Neither needs to be a protocol role. Likewise, authors
would retain default rights over their own contributions, including updating
their PRs and changing their lifecycle status. Ordinary comments, reviews, and
test reports would remain open to participants without repository permissions.

### Apply the grants to PR updates

This would supersede my narrower suggestion in issue #2524. An update would be
eligible when its signer is the original PR author, the repository owner, or
someone granted `update-pr` permission. The referenced PR must belong to the
repository granting that permission.

Among eligible updates, I propose choosing the greatest `created_at`, breaking
ties by the lexicographically smallest event ID. Without an eligible update, the
original PR revision remains selected. This gives clients a common rule without
inventing a special maintainer privilege for this event kind.

### Publish state under the owner's repository address

For kind `30618` repository-state events, I propose replacing the repository
identifier in the `d` tag with the full repository address, and adding the same
address as an explicit `a` reference:

```json
[
  ["d", "30617:<company-pubkey>:widget"],
  ["a", "30617:<company-pubkey>:widget"],
  ["refs/heads/master", "<commit-id>"],
  ["HEAD", "ref: refs/heads/master"]
]
```

The event is signed by the publisher's own key. The full address prevents one
publisher's announcements for identically named repositories under different
owners from replacing each other. Clients discover these events through the
repository reference and check the signer's authority for every advertised ref.
An event advertising any ref outside the signer's authority would be rejected.
A staging-only grant therefore cannot authorize an event advertising `master`
as well.

Each publisher's latest event would be a snapshot of the refs it asserts.
Omission withdraws that publisher's assertion; it does not delete a Git ref or
another publisher's assertion. For each ref, clients compare assertions from
these latest snapshots, choosing the greatest `created_at`, then the smallest
event ID. `HEAD` must agree with an authorized advertised branch; it cannot
introduce additional write authority.

This produces a deterministic view from the same available events. It does not
make timestamps a lock or prevent concurrent Git pushes. Git hosts must still
check the expected previous ref value when applying competing updates. Ref
deletion would need an explicit representation rather than overloading omission.

### Include integration refs

I propose allowing any valid Git ref name under `refs/` as a state-announcement
tag. The same scoped `update-ref` permission would apply regardless of
namespace. A publisher could then advertise:

```json
[
  ["refs/heads/master", "<integrated-commit-id>"],
  ["refs/stage/master/head", "<staged-commit-id>"],
  ["refs/stage/master/nightly/latest", "<snapshot-commit-id>"]
]
```

This would let independently operated testers choose how to trigger builds. Some
could build on a fixed schedule. Others could subscribe to staging-state
announcements and schedule a build when the advertised commit changes. A
repeated announcement of the same commit need not trigger another build. Nightly
snapshots would still provide a common revision for scheduled testing.

The announcement identifies work available for testing; each tester decides
whether and when to build it. No central build scheduler is required, and the
protocol need not prescribe the `refs/stage/` convention to support it.

### Assign scoped tags

A scoped tag consists of a dimension and a value. Projects choose both; the
protocol does not reserve `workflow` or define a fixed set of dimensions. For
example, one PR could have these assignments at the same time:

- `workflow`: `under-review`
- `priority`: `high`
- `component`: `api`

[NIP-32](https://github.com/nostr-protocol/nips/blob/master/32.md) already
provides labeling events. I propose a repository-scoped convention for kind
`1985`. Assigning `workflow:under-review` would look like this:

```json
[
  ["a", "30617:<company-pubkey>:widget"],
  ["e", "<original-pr-event-id>"],
  ["L", "nip34.tag.workflow"],
  ["l", "under-review", "nip34.tag.workflow"]
]
```

The `a` tag identifies the repository, and the `e` tag identifies the issue or
original PR. Within this convention, the repository reference provides scope;
the contribution is the assignment target. The target must belong to that
repository. The label namespace is `nip34.tag.<dimension>`; here the dimension
is `workflow`, and the value is `under-review`. The signer must be the
repository owner or have `set-tag` permission for that exact dimension.
Dimensions and values are case-sensitive, and the same dimension name in
different repositories need not have the same meaning. Bob's grant above
allows this assignment, but does not allow him to assign `priority:high`.

Each assignment event targets one contribution and one dimension. Under this
proposal, each dimension has one current value per contribution. The latest
eligible assignment replaces the previous value in that dimension, using the
same timestamp and event-ID ordering as PR updates. An event containing the
`L` tag without an `l` value clears the dimension. Assigning or clearing
`workflow` leaves `priority` and `component` unchanged. These replacement rules
apply only to this convention, not to arbitrary NIP-32 labels.

Assignments apply to the original issue or PR identity and persist until
replaced or cleared. A new PR revision does not automatically clear its tags.
If a project wants to reset `workflow` after a revision, an authorized
participant or service publishes that change. Labels from users without the
required permission remain observations rather than project assignments.

Clients can display dimensions and values without knowing their meaning. A
project may use `workflow` to drive automation, `priority` for sorting, and
`component` for filtering. Those interpretations belong to the project; the
protocol defines how assignments are scoped, authorized, and replaced.

### Enforce the same permissions in every application

Alice's permission to update `refs/heads/master` should mean the same thing
whether she uses a Git client, GitWorkshop, a Git server, or an integration
service.

One implementation might authenticate Alice and accept her push. Another might
accept her signed request to merge a PR and perform the Git operation on her
behalf. There should be no separate permission vocabulary for requesting work
through automation.

An integration service must check that the requester has permission for the
operation. The service also needs its own permission to execute the operation
and publish its result. Giving a service broad permissions must not allow a less
privileged user to obtain the same authority by asking it to act.

In the example, Bob can change staging refs and tags in the `workflow` dimension,
but cannot update `master`. Carol can revise contributions and change lifecycle
status without receiving branch-write access. The automation can carry out any
of their authorized tasks, but must reject requests outside the requester's
authority.

A workflow transition must not bypass ref permissions either. If a service
merges a PR when its `workflow` tag becomes `ready-to-merge`, it must check that
the requester can both assign that tag and update the destination ref. Permission
to assign a tag alone does not grant branch-write access.

Git hosts need to enforce this too. A signed grant does not automatically
configure an SSH account or a receive hook. Hosts adopting the model need to
connect authenticated Git users to their Nostr identities and check the relevant
ref permissions. Clients should independently verify received state
announcements.

## Policy changes and compatibility

The `permissions` marker makes the authorization mode explicit. Without it,
clients retain the existing NIP-34 behavior. With version `1`, explicit grants
and the owner and author defaults govern these operations; the legacy
`maintainers` list must not silently add permissions. An empty explicit grant
list is therefore meaningful.

Existing clients would need updates to understand this model, including the
extended state-announcement format. A project cannot assume an older client will
enforce restrictions it does not understand. During migration, publishing legacy
maintainer information must not contradict the intended permissions.

Applications would subscribe to policy changes and recheck permissions before
executing pending work. Removing an employee's grant should prevent new work
without requiring a service restart. Removing a bot's grant should stop it too.

Historical validation needs more design. Events could reference the exact
owner-signed announcement that authorized them, but addressable announcements
may be pruned by relays. A policy reference also does not prove that an
operation preceded revocation: an old grant can be referenced later, and
timestamps can be backdated. Immediate revocation cannot be guaranteed to an
offline participant.

I would keep completed Git history intact and reauthorize pending operations
against the latest known policy. A formal proposal still needs a precise rule
for historical event validity, retention of permission history, and delayed
updates. It also needs to define ref deletion and the treatment of unrelated
branch histories. These are limits of this sketch, rather than details that
implementations should each resolve differently.

## Introducing Robert

I am building an integration bot called Robert the Robot to implement the
staging and review workflow from my earlier post. It recognizes signed
discussion commands, maintains staging refs, and merges authorized
contributions. Its current design uses configured maintainer roles and the bot's
identity for repository announcements; the permission extension described here
is not implemented.

With this extension, Robert could consume an owner's announcements and act as an
employee of the project. A project relying on it could grant it all operational
permissions while granting people narrower responsibilities. Direct pushes,
interactive clients, and other automation would remain equally valid ways to
work with the repository.

The common foundation would be the repository's identity and permissions.
Applications would implement different workflows on top of that foundation.
