# iac-modules

Reusable OpenTofu / Terraform modules for the [`kholisrag/labirin`](https://github.com/kholisrag/labirin)
infrastructure and anything else that wants them. Each module lives in its own top-level
directory, is versioned independently, and is released by
[release-please](https://github.com/googleapis/release-please).

## Repository layout

```
iac-modules/
├── <module-name>/                  # one directory per module
│   ├── main.tf | main.tofu
│   ├── variables.tf | variables.tofu
│   ├── outputs.tf | outputs.tofu
│   ├── versions.tf | versions.tofu
│   ├── CHANGELOG.md                # maintained by release-please
│   └── README.md
├── release-please-config.json      # per-module release configuration
├── .release-please-manifest.json   # current version of every module
└── .github/workflows/
    ├── release.yaml                # release-please + per-module orphan tags
    ├── pr-title-lint.yaml          # Conventional Commit PR titles
    └── validate.yaml               # tofu fmt + init/validate per module
```

Naming convention: `<provider>-<service>`, e.g. `aws-vpc`, `proxmox-networks-linux-bridges`,
`kubernetes-manifests-talos`. Modules contain **no provider configuration blocks** — providers
are inherited from the consuming root module / Terragrunt `root.hcl`.

## Consuming a module

Every release publishes an **orphan tag whose root is the module itself**, so consumers
reference the repo without a `//<subdir>` selector:

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git?ref=aws-vpc/v0.1.0"
}
```

Three tags are published per release:

| Tag | Meaning |
| --- | --- |
| `<module>/v0.1.0` | immutable, exact release — **use this in production** |
| `<module>/v0.1` | floating, latest patch of that minor |
| `<module>/v0` | floating, latest minor of that major |

release-please additionally creates a `<module>-v0.1.0` tag on `main` (the merge commit).
That one needs the subdirectory form if you prefer it:

```hcl
terraform {
  source = "git::https://github.com/kholisrag/iac-modules.git//aws-vpc?ref=aws-vpc-v0.1.0"
}
```

Pin exact versions in production; floating `v0` / `v0.1` tags are for scratch and test stacks.

## Module catalog

Current versions live in [`.release-please-manifest.json`](./.release-please-manifest.json).

### AWS

| Module | Upstream |
| --- | --- |
| [`aws-ecr`](./aws-ecr) | `terraform-aws-modules/ecr/aws` @ `3.1.0` |
| [`aws-eks`](./aws-eks) | `terraform-aws-modules/eks/aws` @ `21.10.1` |
| [`aws-eks-pod-identity`](./aws-eks-pod-identity) | `terraform-aws-modules/eks-pod-identity/aws` @ `2.5.0` |
| [`aws-github-actions-oidc-role`](./aws-github-actions-oidc-role) | `voquis/github-actions-oidc-role/aws` @ `0.0.5` |
| [`aws-kms`](./aws-kms) | `terraform-aws-modules/kms/aws` @ `4.1.1` |
| [`aws-vpc`](./aws-vpc) | `terraform-aws-modules/vpc/aws` @ `v6.5.1` |

### Kubernetes

| Module | Upstream |
| --- | --- |
| [`kubernetes-manifests-eks`](./kubernetes-manifests-eks) | in-house |
| [`kubernetes-manifests-gke`](./kubernetes-manifests-gke) | in-house |
| [`kubernetes-manifests-talos`](./kubernetes-manifests-talos) | in-house |

### Proxmox VE

| Module | Upstream |
| --- | --- |
| [`proxmox-acl`](./proxmox-acl) | in-house |
| [`proxmox-apt-repository`](./proxmox-apt-repository) | in-house |
| [`proxmox-apt-standard-repository`](./proxmox-apt-standard-repository) | in-house |
| [`proxmox-certificate`](./proxmox-certificate) | in-house |
| [`proxmox-cluster-firewall`](./proxmox-cluster-firewall) | in-house |
| [`proxmox-cluster-firewall-security-group`](./proxmox-cluster-firewall-security-group) | in-house |
| [`proxmox-cluster-options`](./proxmox-cluster-options) | in-house |
| [`proxmox-containers`](./proxmox-containers) | in-house |
| [`proxmox-dns`](./proxmox-dns) | in-house |
| [`proxmox-download-files`](./proxmox-download-files) | in-house |
| [`proxmox-files`](./proxmox-files) | in-house |
| [`proxmox-firewall-aliases`](./proxmox-firewall-aliases) | in-house |
| [`proxmox-firewall-ipsets`](./proxmox-firewall-ipsets) | in-house |
| [`proxmox-firewall-options`](./proxmox-firewall-options) | in-house |
| [`proxmox-firewall-rules`](./proxmox-firewall-rules) | in-house |
| [`proxmox-groups`](./proxmox-groups) | in-house |
| [`proxmox-hagroup`](./proxmox-hagroup) | in-house |
| [`proxmox-hardware-mapping-pci`](./proxmox-hardware-mapping-pci) | in-house |
| [`proxmox-hardware-mapping-usb`](./proxmox-hardware-mapping-usb) | in-house |
| [`proxmox-haresource`](./proxmox-haresource) | in-house |
| [`proxmox-hosts`](./proxmox-hosts) | in-house |
| [`proxmox-networks-linux-bridges`](./proxmox-networks-linux-bridges) | in-house |
| [`proxmox-networks-linux-vlans`](./proxmox-networks-linux-vlans) | in-house |
| [`proxmox-pools`](./proxmox-pools) | in-house |
| [`proxmox-roles`](./proxmox-roles) | in-house |
| [`proxmox-time`](./proxmox-time) | in-house |
| [`proxmox-user-tokens`](./proxmox-user-tokens) | in-house |
| [`proxmox-users`](./proxmox-users) | in-house |
| [`proxmox-vms`](./proxmox-vms) | in-house |

## Releasing

Releases are fully automated:

1. Open a PR whose **title** is a [Conventional Commit](https://www.conventionalcommits.org/)
   (`pr-title-lint.yaml` enforces this — squash-merge uses the PR title as the commit message).
   Scope the change to the module(s) you touched.
2. Merge to `main`. `release.yaml` runs release-please, which opens/updates a release PR
   containing the version bump and `CHANGELOG.md` entry for every module with pending changes.
3. Merge the release PR. release-please tags `<module>-vX.Y.Z` and creates the GitHub Release;
   the `create-module-tag` job then pushes the `<module>/vX`, `<module>/vX.Y` and
   `<module>/vX.Y.Z` orphan tags, and `upload-artifact` attaches a zip of the module.

Version bumps follow `bump-minor-pre-major` semantics while modules are pre-1.0:

| Commit type | Bump |
| --- | --- |
| `fix:` | patch (`0.1.0` → `0.1.1`) |
| `feat:` | minor (`0.1.0` → `0.2.0`) |
| `feat!:` / `BREAKING CHANGE:` | minor while `0.x` (`0.1.0` → `0.2.0`) |

## Adding a new module

1. Create `<provider>-<service>/` with `main`, `variables`, `outputs` and `versions` files.
   Use the `.tofu` extension only if the module relies on OpenTofu-specific syntax.
2. Register it in `release-please-config.json`:

   ```json
   "<module-name>": {
     "component": "<module-name>",
     "changelog-path": "CHANGELOG.md",
     "release-type": "terraform-module",
     "bump-minor-pre-major": true,
     "bump-patch-for-minor-pre-major": false,
     "draft": false,
     "prerelease": false
   }
   ```

3. Add `"<module-name>": "0.0.0"` to `.release-please-manifest.json`.
4. Open the PR with a `feat:` title. The first merge cuts `v0.1.0`.

## Conventions

- Wrapper modules pin the upstream registry module to an exact version in `main.tf`.
  Bumping that pin is a `feat:` (or `fix:`) commit on this repo — the module version and the
  upstream version are deliberately decoupled.
- No `provider {}` blocks inside modules; `versions.tf` declares `required_providers` only.
- Changing a resource address (adding `count`/`for_each`, renaming) is a consumer migration:
  ship a `moved {}` block for static renames, and call out consumer-keyed changes explicitly
  in the changelog.
- `tofu fmt -recursive` must be clean; `validate.yaml` enforces it on every PR.

## Local development

```bash
tofu fmt -recursive .
cd <module-name>
tofu init -backend=false
tofu validate
```

## License

MIT — see [LICENSE](./LICENSE).
