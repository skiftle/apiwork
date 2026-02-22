---
order: 3
---

# Core Concepts

Apiwork is built around a small set of explicit concepts: API definitions, contracts, representations, and adapters. Together, they define the boundary of your application in a way that is structured and introspectable.

Each concept has a clear responsibility. They form a layered system that connects your Rails domain to the outside world without replacing it.

This section explains how these pieces fit together. It does not go into usage details. Its purpose is to clarify how responsibility flows through the system.

## API Definitions

[API definitions](../core/api-definitions/introduction.md) describe the surface of your API.

They declare which resources exist, how they are nested, which exports should be generated, and how the boundary is configured. They define the base path of the API, decide which resources are exposed, and specify which artifacts — such as OpenAPI, TypeScript, or Zod — are derived.

API definitions are also where boundary-level configuration lives: key formatting, adapter selection, adapter options, and global defaults that shape how the API behaves externally.

They define structure and configuration at the boundary. They do not execute validation or runtime behavior.

## Contracts

[Contracts](../core/contracts/introduction.md) define the boundary itself.

A contract describes what a request accepts and what a response returns. Incoming data is validated before it reaches your domain logic. Outgoing data is shaped according to explicit definitions. If input does not conform, it is rejected at the boundary.

Contracts are written using a declarative DSL. Instead of validating parameters imperatively inside controllers, you describe the structure of the boundary directly in Ruby. The DSL keeps definitions concise while enforcing strictness at the edge of the system.

Contracts run at runtime. They are not passive schemas written only for documentation. The same definitions that validate requests in production also describe the API externally.

Structure is defined once. It runs in production and is available through introspection. There is no second schema to maintain.

Contracts can be written entirely by hand. They are the fundamental building block in Apiwork.

## Representations

[Representations](../core/representations/introduction.md) connect contracts to your domain models.

When working with ActiveRecord-backed endpoints, representations remove duplication by using metadata Rails already derives from your models and database. Column types, enums, nullability, and associations are not redefined — they are surfaced at the boundary.

A representation declares which attributes are exposed, which are writable, and how relationships appear in responses. It also determines which fields participate in filtering, sorting, pagination, and nested writes.

From this declaration, contracts and runtime behavior are derived consistently.

Representations do not replace your models. The database remains the source of truth. The boundary reflects it explicitly. The domain stays expressive inside — the API remains predictable outside.

Representations are optional. They exist to make conventional APIs declarative instead of manually assembled.

## Adapters

[Adapters](../core/adapters/introduction.md) define the conventions of your API.

While representations describe how a model is exposed, adapters interpret those declarations and turn them into runtime behavior. They derive contracts and define how structure becomes consistent semantics.

An adapter decides how filtering works, how sorting is applied, how pagination behaves, how nested writes are processed, and how relationships are included in responses.

In this way, the adapter turns declarative intent into concrete behavior. It captures the conventions of your API and applies them consistently.

## Introspection

[Introspection](../core/introspection/introduction.md) makes the boundary self-describing.

The structure defined by API definitions, contracts, representations, and adapters is available as a coherent model. The system can inspect the same definitions that drive execution and derive a complete description of the API.

All exports — including OpenAPI specifications, TypeScript definitions, and Zod schemas — are derived from this model.

Execution and generation rely on the same structure. What runs in production is what is exported.

## Errors

[Errors](../core/errors/introduction.md) are part of the boundary.

Apiwork enforces a unified error structure across the system. Errors can occur at different layers — transport-level responses, contract validation failures, or domain-level rejections — but a request fails in only one layer. If contract validation fails, domain logic does not run.

All error responses share a consistent format. Each response indicates where the failure occurred and describes the issues found. Because the structure is predictable, clients can handle errors programmatically without guessing the shape.

Success and failure follow the same boundary rules.

## How the Concepts Relate

The system follows a clear direction. ActiveRecord models define the underlying data and relationships. Representations declare how that data is exposed at the boundary. Adapters interpret those declarations and derive executable contracts. Contracts validate incoming requests and shape outgoing responses at runtime. Introspection exposes the resulting model for tooling and exports.

Structure is defined once. It is interpreted consistently, executed at runtime, and described through introspection.

Rails remains dynamic internally. Apiwork makes the external boundary explicit, structured, and contract-driven — without introducing a parallel system.
