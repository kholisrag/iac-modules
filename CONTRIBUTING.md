# Contributing

## Commit messages decide versions

Every module in this repository is versioned by
[release-please](https://github.com/googleapis/release-please) from
[Conventional Commits](https://www.conventionalcommits.org/). Pull requests are
squash-merged, so **the pull request title becomes the commit subject** that
release-please reads — `pr-title-lint.yaml` is what checks it.

Scope the subject to the module, and use the directory name:

```
feat(cloudflare-tunnel): publish the CNAME target as an output
fix(aws-eks): the node group waits for the cluster to be ACTIVE
```

A commit touching two modules names both, comma-separated. Both get a release.

## `!` buys a CHANGELOG section, never a version digit

**Every module here is below `1.0.0`, and every package in
`release-please-config.json` carries `bump-minor-pre-major: true` with
`bump-patch-for-minor-pre-major: false`.** Read it rather than trusting this
line:

```bash
jq '.packages["cloudflare-tunnel"]' release-please-config.json
```

Below `1.0.0` semver cannot keep all three bump kinds distinct, and that
configuration collapses two of them: **a breaking change and a feature both move
the minor digit.** `feat` and `feat!` cut the same version.

So the `!` is not how you make the number move — it cannot. What it does is emit
the `### ⚠ BREAKING CHANGES` section in the module's `CHANGELOG.md`, carrying the
text of your `BREAKING CHANGE:` footer. **Under this configuration that section
is the only place a break is recorded at all**, because the version digit no
longer distinguishes one.

### When to type it

**When moving the `ref=` is not sufficient — when the consumer must do something
else, before or after.** Run a command, edit a call site, accept an outage,
change a pipeline.

Not on every incompatible interface change. Two commits in this repository
show the difference:

| Commit | Consumer's experience | Typed |
| --- | --- | --- |
| `1008e2b` — `prevent_destroy` on the tunnel resource | `destroy` now fails; the remedy is a manual `tofu state rm` | `feat!` |
| `49c8277` — deprecated attributes dropped from whole-resource outputs | a no-op plan; resource addresses unchanged | `fix` |

`49c8277` removed published attributes knowingly, and `fix` is correct: nobody
had to do anything. A `### ⚠ BREAKING CHANGES` block on a release that needs no
act is a block consumers learn to skip — and the next one carries `state rm`.

**Where it is genuinely unclear whether anyone must act, type the `!` and let
the footer say who is affected.** The failure modes are not symmetric: an
unnecessary section is noise, a missing one is a consumer finding out from a
failed `apply`.

### What the footer says

**What to do, not what changed** — the subject line already said what changed.
`1008e2b`'s is the shape to copy:

```
BREAKING CHANGE: `destroy` now fails on any stack consuming this module. A
tunnel is removed by taking it out of state first — see `## Things that bite`
in the module README for both address shapes and for why `-exclude` is not the
answer.
```

A footer that only restates the subject emits a section with no remedy in it.

### After `1.0.0`

The bar above does not change; its price does. At or above `1.0.0` the same `!`
cuts a **major**, so the collapse this section is built on ends. No module is
close to that today — if one is proposed for `1.0.0`, this section is worth
re-reading first.

## Before opening a pull request

`validate.yaml` runs `tofu fmt -check -recursive -diff .` once, then `tofu init
-backend=false -input=false` and `tofu validate` in a matrix over
`jq '.packages | keys' release-please-config.json` — so **a module missing from
that file is never validated.** OpenTofu 1.10.7. Run the same locally:

```bash
tofu fmt -recursive
cd <module> && tofu init -backend=false -input=false && tofu validate
```

**CI runs OpenTofu and only OpenTofu.** Several modules advertise
`### OpenTofu / Terraform` in their README, and nothing here can verify the
second half — so a construct Terraform rejects and OpenTofu accepts passes every
check in this repository. `prevent_destroy` is one: it takes a literal under
both, and a variable under OpenTofu alone. If you touch a module whose README
claims Terraform, run `terraform validate` against it by hand.
