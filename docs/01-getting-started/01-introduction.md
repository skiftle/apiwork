# Introduction

Apiwork is a contract-driven, schema-aware API framework for Rails.

## The Problem

Rails developers often combine several libraries: one for serialization, one for documentation, one for filtering, one for pagination, one for validation, one for TypeScript generation. Each solves a fragment of the problem. None talk to each other.

The result is duplication, drift, and maintenance overhead. Documentation falls out of sync. Types are defined twice. Filter logic is scattered.

## The Solution

Apiwork brings these concerns together into one coherent system built around a single principle: **the contract is the source of truth**.

A contract describes exactly what an endpoint accepts and returns. From that single definition, Apiwork generates:

- Request validation and coercion
- Response serialization
- OpenAPI documentation
- TypeScript types
- Zod schemas
- Filter and sort capabilities

Because everything flows from one place, it stays in sync automatically.

## Why Contracts?

An API is a boundary. Inside Ruby, dynamic typing works beautifully — models, controllers and helpers communicate freely. But once data crosses that boundary to TypeScript, Swift or Kotlin clients, they need well-defined structures.

Apiwork finds a middle ground. You keep Ruby's expressiveness and Rails conventions. Apiwork adds the structure modern clients expect — without bolting a static type system onto Ruby.

## Why Schemas?

Contracts alone can take you far. But you're still hand-describing structures that already exist in your models.

Schemas change that. They map ActiveRecord models directly into Apiwork's metadata — column types, enums, associations, constraints. Instead of repeating what Rails already knows, Apiwork builds on it.

Contracts give you control. Schemas give you leverage.

## Works With Rails

Apiwork acts as a preparation layer. It validates and shapes input, then hands clean data to Rails:

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end
```

`contract.body[:invoice]` is already validated, coerced and shaped for ActiveRecord. For nested associations, Apiwork maps `lines` to `lines_attributes` automatically.

Apiwork doesn't replace ActiveRecord validations or callbacks. It prepares the data so Rails can do what Rails is good at.
