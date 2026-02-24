---
order: 3
---

# Core Concepts

Apiwork is built on a chain of concepts, each with one job. You describe the domain. Apiwork builds the boundary from it — validation, querying, serialization, exports — all from the same description.

## API Definitions

[API definitions](./api-definitions/) describe the surface of the API.

They declare which resources exist, how they are nested, and which outputs to generate — OpenAPI, TypeScript, or Zod. They also set boundary-level configuration: base path, key formatting, adapter selection, and global defaults.

Everything else — validation, querying, serialization — is handled by the layers below.

## Contracts

[Contracts](./contracts/) are the boundary rules.

A contract describes what a request accepts and what a response returns. Incoming data is validated before it reaches domain logic. If input doesn't match, it's rejected.

Contracts use a declarative Ruby DSL. You describe the shape — Apiwork validates it at runtime. The same definitions that reject bad requests in production also generate your OpenAPI, TypeScript, and Zod.

Contracts can be written entirely by hand. They are the fundamental building block in Apiwork.

## Representations

[Representations](./representations/) connect contracts to ActiveRecord models.

Instead of redefining column types, enums, nullability, and associations at the boundary, a representation uses what Rails already knows. You declare which attributes are exposed, which are writable, and how relationships appear — Apiwork builds contracts from that.

Representations are optional. Without ActiveRecord, you write contracts directly.

## Controllers

[Controllers](./controllers/) are the integration point.

A controller includes `Apiwork::Controller`, accesses validated parameters through `contract`, and returns data through `expose`. The adapter handles serialization, error mapping, and response shaping.

Controllers call domain methods and expose the result. The rest happens automatically.

## Adapters

[Adapters](./adapters/) turn declarations into behavior.

A representation says which attributes are filterable. The adapter decides *how* filtering works — which operators, what query format, how parameters are validated. The same applies to sorting, pagination, nested writes, and includes.

Apiwork includes a [standard adapter](./adapters/standard-adapter/). Custom adapters can define different conventions.

## Introspection

[Introspection](./introspection/) makes the boundary inspectable.

Apiwork reads the same definitions that run at runtime and builds a complete model of the API. All exports — OpenAPI, TypeScript, Zod — come from this model.

What runs in production is what gets exported.

## Errors

[Errors](./errors/) are part of the boundary.

Errors happen at different layers — HTTP, contract validation, or domain rules — but a request fails in only one layer. If contract validation fails, domain logic doesn't run.

All error responses share a consistent shape. Clients can handle them programmatically.

## How the Concepts Relate

The chain flows in one direction:

ActiveRecord models define the data. Representations declare how that data is exposed. Adapters read those declarations and build contracts. Contracts validate requests and shape responses at runtime. Introspection reads the same definitions and generates exports.

One description flows through the entire stack. Nothing is defined twice. Nothing drifts.
