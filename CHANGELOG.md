# Changelog

## [0.2.0](https://github.com/kholisrag/iac-modules/compare/cloudflare-tunnel-v0.1.2...cloudflare-tunnel-v0.2.0) (2026-08-06)


### ⚠ BREAKING CHANGES

* **cloudflare-tunnel:** `destroy` now fails on any stack consuming this module. A tunnel is removed by taking it out of state first — see `## Things that bite` in the module README for both address shapes and for why `-exclude` is not the answer.

### Features

* **cloudflare-tunnel:** guard the tunnel resource with prevent_destroy ([#17](https://github.com/kholisrag/iac-modules/issues/17)) ([1008e2b](https://github.com/kholisrag/iac-modules/commit/1008e2b4cfc7a5d4e16e56dfcadbfbe15573d9ae))

## [0.1.2](https://github.com/kholisrag/iac-modules/compare/cloudflare-tunnel-v0.1.1...cloudflare-tunnel-v0.1.2) (2026-08-04)


### Bug Fixes

* **cloudflare-tunnel,cloudflare-zero-trust-access:** whole-resource outputs skip deprecated attributes ([#15](https://github.com/kholisrag/iac-modules/issues/15)) ([49c8277](https://github.com/kholisrag/iac-modules/commit/49c827717232ac982770088e35fa2ec952d34789))

## [0.1.1](https://github.com/kholisrag/iac-modules/compare/cloudflare-tunnel-v0.1.0...cloudflare-tunnel-v0.1.1) (2026-08-04)


### Bug Fixes

* **cloudflare-tunnel:** the whole-tunnel output is sensitive, because tunnel_secret is ([#13](https://github.com/kholisrag/iac-modules/issues/13)) ([fe90584](https://github.com/kholisrag/iac-modules/commit/fe905842c5add3cd10cdc63d9451f304e025955b))

## 0.1.0 (2026-07-26)


### Features

* init cloudflare modules ([837d14f](https://github.com/kholisrag/iac-modules/commit/837d14fa2d11ba39928d271cffdf208954bde9db))
