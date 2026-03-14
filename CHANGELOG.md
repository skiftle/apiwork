# Changelog

## [0.5.0](https://github.com/skiftle/apiwork/compare/apiwork/v0.4.0...apiwork/v0.5.0) (2026-03-14)


### ⚠ BREAKING CHANGES

* move default and example to concrete param types

### Features

* add record param type for key-value maps with typed values ([e2339f3](https://github.com/skiftle/apiwork/commit/e2339f37ef358809f89188dd9fafbdc7ccf994c3))
* add unknown as a param type ([46e4765](https://github.com/skiftle/apiwork/commit/46e47652c132e8ebd389a4ca859b2bb89899c108))
* move default and example to concrete param types ([f20e082](https://github.com/skiftle/apiwork/commit/f20e0821a7378eca839a663d0c876bf6648e51ab))


### Bug Fixes

* allow referencing types named after DSL keywords in union variants ([be526bb](https://github.com/skiftle/apiwork/commit/be526bbf23e95bdb0b536ce094d665dd1b76951d))
* omit ErrorSchema from sorbus contract when no raises are declared ([df06c22](https://github.com/skiftle/apiwork/commit/df06c2230857fd791c23aa7fb19dddee880f5128))
* produce complete param hashes for of-elements in introspection dump ([99b7ec4](https://github.com/skiftle/apiwork/commit/99b7ec43e8a47fa2e8e9746fcb8498c53bbc36e9))
* return null body for no_content responses in introspection ([5f8845b](https://github.com/skiftle/apiwork/commit/5f8845b90afaf91f2c94fb512984763c0d0f11bc))
* select hub node as cycle breaker and iterate until all cycles resolved ([c66bfb2](https://github.com/skiftle/apiwork/commit/c66bfb28fbc362b7de622ab40792e85276748ef4))
* skip primitive types when resolving type references in introspection dump ([0970b5b](https://github.com/skiftle/apiwork/commit/0970b5b2d31b4c765955134fcb0501ea7c7e8eb8))
* use custom_type to resolve type references in introspection ([41d1c5b](https://github.com/skiftle/apiwork/commit/41d1c5be74840b6bb9c1d2da5412dbb6cce79aed))
* use type definition scope for enum resolution during type expansion ([70fbdbf](https://github.com/skiftle/apiwork/commit/70fbdbf7932ffb5aebc913274ded6b1aabfe2023))

## [0.4.0](https://github.com/skiftle/apiwork/compare/apiwork/v0.3.1...apiwork/v0.4.0) (2026-03-09)


### ⚠ BREAKING CHANGES

* add locales DSL for declaring supported API locales

### Features

* add :text string format for multiline text hints ([4c6cf17](https://github.com/skiftle/apiwork/commit/4c6cf1736049eedeb27dec23d3c528e5073f874e))
* add fingerprint to API for stable client-side identification ([dc581aa](https://github.com/skiftle/apiwork/commit/dc581aa1e2d4550b75811cdd792f64df7dd5c599))
* add locales DSL for declaring supported API locales ([2286a69](https://github.com/skiftle/apiwork/commit/2286a69c6e8bc718dafe916d3bddb332624553ac))


### Bug Fixes

* accept empty objects and arrays for required fields in validation ([e21b938](https://github.com/skiftle/apiwork/commit/e21b938cdf3bdf6650a5c0c828a3cc1f07d965a5))
* coerce primitive union variants for filter shorthand ([a2ae2d5](https://github.com/skiftle/apiwork/commit/a2ae2d5ee69b382c2cb8c14dd5fed181bc4b385b))
* include parent path segments in introspection resource paths ([3e8f977](https://github.com/skiftle/apiwork/commit/3e8f977e49a9efedeeeb10c8c5fc79723ae1e641))
* merge representation fields into any contract-defined types ([9c8b79f](https://github.com/skiftle/apiwork/commit/9c8b79f449bf252eb823d4466a21a4cb5a9eb2bf))
* promote deeper-path errors in union validation ([0c91493](https://github.com/skiftle/apiwork/commit/0c914936283c184148955ce764862a9c4d7eaaa0))
* remove redundant default? predicate from introspection params ([179f22e](https://github.com/skiftle/apiwork/commit/179f22e3634f074bcda3188b34814367b3abdecd))
* skip empty payload types for read-only representations ([48a114d](https://github.com/skiftle/apiwork/commit/48a114d05670b8c050359b28dda331b185c2fca4))
* use "object" instead of "hash" in union type error meta ([6ce9f27](https://github.com/skiftle/apiwork/commit/6ce9f27708a7ff0e141379e9e28ff90289207ffa))

## [0.3.1](https://github.com/skiftle/apiwork/compare/apiwork/v0.3.0...apiwork/v0.3.1) (2026-03-04)


### Bug Fixes

* generate correct introspection paths for singular resources ([1034545](https://github.com/skiftle/apiwork/commit/10345455c735417b7de46add9445beef4cb1b781))
* use resource param option in introspection action paths ([491dd24](https://github.com/skiftle/apiwork/commit/491dd24955ecd4162dd2ff5554ec31c3d6bab04c))

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
