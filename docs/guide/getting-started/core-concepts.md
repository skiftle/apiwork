# Core Concepts

Apiwork is structured around a small set of explicit concepts: API definitions, contracts, representations, and adapters. Together, they define and interpret a boundary that remains structured and introspectable.

Each concept has a clearly defined responsibility. They form a layered system that connects your Rails domain to the outside world without redefining it.

This section explains how those pieces relate. It does not describe usage in detail. Its purpose is to clarify how responsibility flows through the system.

## API Definitions

API definitions describe your API surface.

They declare which resources exist, how they are nested, which artifacts should be generated, and how the boundary should be configured. They establish the base path of the API, determine which resources are exposed, and specify which exports — such as OpenAPI, TypeScript, or Zod — should be derived.

API definitions are also where boundary-level configuration lives: key formatting strategy, adapter selection, adapter options, and global defaults that shape how the API is experienced externally.

They define structure and configuration at the boundary. They do not execute validation or runtime behavior themselves.

## Contracts

Contracts define the boundary itself.

A contract specifies what a request accepts and what a response returns. Incoming data is validated before it reaches your domain logic. Outgoing data is shaped according to explicit definitions. If input does not conform, it is rejected at the boundary.

Contracts are expressed through a declarative DSL. Instead of imperatively validating parameters in controllers, you describe the structure of the boundary directly in Ruby. The DSL keeps definitions concise while enforcing strictness at the edge of the system.

Contracts execute at runtime. They are not passive schemas written for documentation. The same definitions that validate requests in production describe the API externally.

Structure is declared once. It is executed at runtime and described through introspection. There is no secondary schema to maintain.

Contracts can be written entirely by hand. They are the most fundamental building block in Apiwork.

## Representations

Representations connect contracts to your domain models.

When working with ActiveRecord-backed endpoints, representations remove duplication by reflecting metadata Rails already derives from your models and database. Column types, enums, nullability, and associations are not redefined — they are surfaced deliberately at the boundary.

A representation declares which attributes are exposed, which are writable, and how relationships appear in responses. It also determines which fields participate in conventions such as filtering, sorting, pagination, and nested writes.

From this declaration, contracts and runtime behavior are derived consistently.

Representations do not replace your data model. The database remains the underlying source of truth. The boundary reflects it explicitly. The domain stays expressive on the inside — the API remains predictable on the outside.

Representations are optional. They exist to make conventional APIs declarative rather than manually assembled.

## Adapters

Adapters encode the conventions of your API.

While representations describe how a model is exposed, adapters interpret those declarations and turn them into executable behavior. They derive contracts dynamically and define how declarative structure becomes consistent runtime semantics.

An adapter determines how filtering is interpreted, how sorting is applied, how pagination works, how nested writes are processed, and how relationships are included in responses.

In this sense, the adapter expresses how declarative intent becomes concrete behavior. It captures the conventions of your API and applies them consistently.

## Introspection

Introspection makes the boundary self-describing.

The structure defined by API definitions, contracts, representations, and adapters is available as a coherent model. The system can examine the same definitions that drive execution and derive a complete description of the API.

All exports — including OpenAPI specifications, TypeScript definitions, and Zod schemas — are derived from this model.

Execution and generation rely on the same structure. What runs in production is what is exported.

## Errors

Errors are part of the boundary.

Apiwork enforces a unified error structure across the system. Errors occur in distinct layers — transport-level responses, contract validation failures, or domain-level rejections — and a request fails in only one layer. If contract validation fails, domain logic does not run.

All error responses share a consistent structure. Each response identifies where the failure occurred and describes the issues found. Because the format is deterministic, clients can respond programmatically without relying on unpredictable error shapes.

Success and failure follow the same boundary rules.

## How the Concepts Relate

The system forms a directional model. ActiveRecord models define the underlying data and associations. Representations declare how that data is exposed at the boundary — which attributes exist, which are writable, and how relationships appear. Adapters interpret those declarations and derive executable contracts. Contracts validate incoming requests and shape outgoing responses at runtime. Introspection exposes the resulting model for tooling and exports.

Structure is declared once. It is interpreted consistently, executed at runtime, and described through introspection.

Rails remains dynamic internally. Apiwork makes the external boundary explicit, structured, and contract-driven — without introducing a parallel system.
