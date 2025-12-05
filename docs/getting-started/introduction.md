---
order: 1
---

# Introduction

Apiwork is built around a simple idea: your API is a boundary, and boundaries need structure.

A contract defines what crosses that boundary — the exact shape of requests and responses. Apiwork validates incoming data before your controller sees it, shapes outgoing data after, and generates documentation from the same source.

## The Problem

Inside Rails, Ruby's flexibility works in your favor. Conventions make explicit types feel unnecessary. But the moment data leaves your server and reaches a TypeScript, Swift, or Kotlin client, those conventions vanish. The client has no idea what shape to expect unless you tell it.

You end up defining the same structure in multiple places: strong parameters, serializers, API docs, client types. They drift apart. Bugs happen.

## The Solution

Define it once. Use it everywhere.

**Contracts** declare what your API accepts and returns. Apiwork validates requests before they reach your controller and checks responses in development. Invalid data gets rejected with structured errors — codes, messages, and JSON Pointer paths to the exact field that failed.

**Schemas** connect contracts to your models. But here's the key: your database already knows the structure. Column types, nullability, enums, associations — it's all there. Schemas inherit this automatically. You just declare what to expose:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :title, filterable: true
  attribute :status, sortable: true
  attribute :body, writable: true
  has_many :comments
end
```

From this, Apiwork knows: title is a string (from the column), status is an enum (from the model), body can be written, comments can be included. No duplicate type definitions.

**The adapter** handles query operations. Filtering, sorting, pagination, eager loading — the mechanics that every API needs but nobody wants to write repeatedly. You configure it once at the API level, and it works across all endpoints.

**Spec generation** produces OpenAPI, TypeScript types, and Zod schemas. Same contracts, multiple outputs. Your docs and client types stay in sync because they come from the same place.

## One Source of Truth

This is the core idea: contracts, schemas, and specs all derive from the same metadata. Change a type in your schema, and the TypeScript types update. Add a filter, and OpenAPI reflects it. Remove a field, and clients get type errors at compile time instead of runtime surprises.

```
Database → Schema → Contract → OpenAPI / TypeScript / Zod
              ↓         ↓
          Serialize  Validate
          Filter     Coerce
          Sort       Transform
          Paginate
```

## Still Rails

Apiwork doesn't replace how you write Rails apps. Your controllers stay familiar. Your models keep their validations, callbacks, and business logic. Apiwork just adds structure at the edges — what goes in, what comes out.

You write `respond_with Post.all` and get filtering, sorting, and pagination. You mark an attribute `writable: true` and nested creates work. You add `filterable: true` and clients can filter by that field.

Declarative. Conventional. Explicit.

## What's Next

- [Installation](./installation.md) — add Apiwork to your project
- [Core Concepts](./core-concepts.md) — API definitions, contracts, schemas
- [Quick Start](./quick-start.md) — build a complete endpoint
