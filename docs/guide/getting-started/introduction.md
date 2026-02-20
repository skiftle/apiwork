---
order: 1
---

# Introduction

Apiwork is a contract-driven API layer for Rails. Instead of letting your API boundary emerge from scattered controllers, serializers, and documentation, you define it once — and that definition validates requests, shapes responses, and generates your documentation and client types.

## The Boundary Defined

At its core are _contracts_. A contract defines what a request accepts — parameters, types, structure — and validates it before your domain logic runs. Invalid requests are rejected with structured errors. There is no separate validation layer and no manual type checking in controllers.

The contract _is_ the boundary — and it executes at runtime.

## The Domain Reflected

You can write contracts entirely by hand. But for endpoints that expose ActiveRecord models, _representations_ remove much of that burden.

A representation describes how a model appears through the API — which attributes are visible, which are writable, and how associations are exposed — by building on metadata Rails already knows from your models and database: column types, enums, nullability, and associations.

The database remains the underlying source of truth. The API boundary reflects it deliberately. The domain stays expressive and dynamic on the inside — the boundary makes it explicit.

## Conventions Captured

From representations, _adapters_ derive contracts and implement runtime behavior. An adapter encodes the conventions of your API — how filtering works, how pagination behaves, how nested writes are processed — and applies them consistently across endpoints.

Apiwork ships with a built-in adapter that handles operator-based filtering, sorting, cursor and offset pagination, nested writes, single-table inheritance, and polymorphic associations. It gives you a powerful API out of the box — but adapters remain a first-class architectural concept. You can implement your own to encode different conventions, performance strategies, or domain-specific behavior.

## Runtime and Specification in Sync

Because the boundary is structured and introspectable, Apiwork derives OpenAPI specifications, TypeScript types, and Zod schemas from the same definitions that validate requests at runtime.

There is no parallel schema to maintain and no drift between runtime behavior and generated artifacts. What runs in production is what your documentation and client types describe.

## Designed for Rails

Apiwork does not replace Rails — it leans into it. Controllers remain controllers. ActiveRecord remains ActiveRecord. Domain logic stays where it belongs.

Apiwork operates at the boundary, strengthening what Rails already does well rather than introducing a parallel architecture.

## A Single Source of Truth

The result is an API boundary that serves as a single source of truth — explicit enough to reason about, structured enough for tooling, and consistent enough to scale across teams and strongly typed clients.

The same definitions that run in production shape your documentation, your client types, and the interface the outside world depends on — allowing Rails to remain dynamic on the inside while the boundary presented to the outside world remains contract-driven and type-safe.
