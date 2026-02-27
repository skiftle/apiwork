# Changelog

## [0.3.0](https://github.com/skiftle/apiwork/compare/apiwork/v0.2.0...apiwork/v0.3.0) (2026-02-27)


### ⚠ BREAKING CHANGES

* remove redundant :error_response_body type
* remove per-action types from type registry
* use plural resource names for per-action types and add request/response wrappers

### Features

* add description to request for OpenAPI exports ([c5685e1](https://github.com/skiftle/apiwork/commit/c5685e142df38c34d82f50921eb4b7c131175e39))
* add description to response for OpenAPI exports ([0df5b82](https://github.com/skiftle/apiwork/commit/0df5b8277bf2e582d6b7c6b17559b96daea890f9))
* add Sorbus export for typed client contracts ([b284cb7](https://github.com/skiftle/apiwork/commit/b284cb7af863e5ac975e0fe53bf6ee7f218ab949))
* expose per-action schema builders for external composition ([530a5d3](https://github.com/skiftle/apiwork/commit/530a5d3c0a3bbfc21286cefa9573f78b3a29c94d))
* remove per-action types from type registry ([ff8d042](https://github.com/skiftle/apiwork/commit/ff8d0420fe168ef5aab9af972ec50c81123b73b0))
* remove redundant :error_response_body type ([3f715cb](https://github.com/skiftle/apiwork/commit/3f715cbe58c30613ba1f412ee4d93274e9355e1a))
* use plural resource names for per-action types and add request/response wrappers ([acde604](https://github.com/skiftle/apiwork/commit/acde60498637dad618a3a922b212ecb9daaff8ea))

## [0.2.0](https://github.com/skiftle/apiwork/compare/apiwork/v0.1.2...apiwork/v0.2.0) (2026-02-26)


### ⚠ BREAKING CHANGES

* replace result_wrapper with symmetric per-action types

### Features

* replace result_wrapper with symmetric per-action types ([a9da6dc](https://github.com/skiftle/apiwork/commit/a9da6dc8e5f69a54552c9a83c5e07b0c02208a32))


### Bug Fixes

* avoid frozen lockfile for playground in CI ([d49da1c](https://github.com/skiftle/apiwork/commit/d49da1c38a7a27236b0e467688f827471be9a2ca))

## [0.1.2](https://github.com/skiftle/apiwork/compare/apiwork/v0.1.1...apiwork/v0.1.2) (2026-02-24)


### Bug Fixes

* add custom domain for GitHub Pages ([a9b48db](https://github.com/skiftle/apiwork/commit/a9b48db83f72d1bae35a3aa0c2888d8860919e64))
* exclude playground vendor from VitePress build ([c691144](https://github.com/skiftle/apiwork/commit/c691144ce16c4a6218f00f06b3c04c74ffb417c9))
* generate reference index.md in ReferenceGenerator ([c1e164e](https://github.com/skiftle/apiwork/commit/c1e164e6d25f5666dd9c1f3a81ed86dcf1025d8a))
* keep playground public directory for docs generation ([97eac92](https://github.com/skiftle/apiwork/commit/97eac92c19b3ded6e9b34c338b74b269c47420e5))
* lazy-load yard in ReferenceGenerator ([ec72f9a](https://github.com/skiftle/apiwork/commit/ec72f9a10025d25e69ea11577587fd2177ca0f41))
* remove dummy app master key from repository ([078c7a3](https://github.com/skiftle/apiwork/commit/078c7a381be6f609482629bdc0d8171b1d53319d))
* use pnpm for docs build ([d8ca0ac](https://github.com/skiftle/apiwork/commit/d8ca0ac93c485b3fb4df669a266d5f62114d3197))

## [0.1.1](https://github.com/skiftle/apiwork/compare/apiwork-v0.1.0...apiwork/v0.1.1) (2026-02-24)


### Features

* initial release ([e633199](https://github.com/skiftle/apiwork/commit/e63319938b2cc35dd7350a39477d53dfb18b1f4b))
