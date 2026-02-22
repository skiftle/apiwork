---
order: 1
---
# Getting Started

Apiwork is a contract-driven API layer for Rails. In many Rails apps, the API boundary is built from controllers, serializers, and documentation over time. The pieces fit, but the structure is implicit.

Apiwork makes that boundary explicit. You define it once, and that definition validates requests, shapes responses, and generates documentation and client types. Rails remains Rails. Apiwork simply makes the edge of your application clear and executable.

## The Boundary Defined

At the core of Apiwork are _contracts_. A contract defines what a request accepts — parameters, types, and structure — and it is executed before your application code runs. Invalid requests never reach your domain logic; they are rejected at the boundary with structured errors. There is no separate validation layer and no manual type checking in controllers. The contract is the boundary, and it runs at runtime.

## The Domain Reflected

You can define contracts entirely by hand. But when exposing ActiveRecord models, _representations_ remove duplication by building on what Rails already knows. A representation describes how a model appears through the API — which attributes are visible, which are writable, and how associations are exposed — using metadata from your models and database: column types, enums, nullability, and relationships.

The database remains the source of truth. Apiwork reflects that truth at the boundary instead of redefining it. Your domain stays expressive and dynamic on the inside, while the API surface becomes explicit and predictable on the outside.

## The Conventions Captured

From representations, _adapters_ derive contracts and implement runtime behavior. An adapter encodes how your API behaves — filtering, sorting, pagination, nested writes — and applies those rules consistently across endpoints. This keeps conventions centralized instead of scattered across controllers and scopes.

Apiwork includes a built-in adapter that supports operator-based filtering, sorting, cursor and offset pagination, nested writes, single-table inheritance, and polymorphic associations. Adapters are first-class architectural components, not hidden internals. You can implement your own to express different conventions, performance strategies, or domain-specific behavior.

## The Specification Derived

Because the boundary is structured and introspectable, Apiwork generates OpenAPI specifications, TypeScript types, and Zod schemas directly from the same definitions that run in production. There is no parallel schema layer and no duplication between validation and generated types. Runtime and specification remain in sync. What executes in production is exactly what your documentation and client types describe.

## Designed for Rails

Apiwork does not replace Rails and does not introduce a parallel architecture. Controllers remain controllers. ActiveRecord remains ActiveRecord. Domain logic stays in the domain. Apiwork operates at the boundary and strengthens what Rails already does well by making the API surface explicit and executable.

## A Single Source of Truth

The result is an API boundary that acts as a single source of truth. It is explicit enough to reason about, structured enough for tooling, and consistent enough to scale across teams and strongly typed clients. The same definitions that validate requests at runtime also define the contract presented to the outside world, allowing Rails to remain dynamic internally while the external interface stays contract-driven and type-safe.
