---
order: 1
---

# Introduction

Apiwork is a contract-driven, schema-aware API framework for Rails. It brings validation, serialization, documentation, filtering, sorting, pagination and code generation together into one coherent system built around a single idea: define things once and keep everything in sync automatically.

## The Problem

Most Rails APIs rely on several separate tools: serializers, strong parameters, documentation generators, validation layers, filter/sort libraries, and hand-written TypeScript, Zod or OpenAPI/spec definitions. Because these tools don’t share metadata, the same structures often end up defined multiple times. As an application evolves, these definitions drift apart, causing documentation to fall out of date, validation and serialization to behave inconsistently, and client-side types to no longer reflect the actual API.

## The Solution

Apiwork solves this by letting the contract act as the single source of truth for each endpoint. A contract specifies what the API accepts and returns. From that definition, Apiwork generates validation, coercion, serialization, OpenAPI documentation, Zod schemas, TypeScript types and metadata for filtering, sorting and pagination.

Schemas extend this by tapping into the information Rails has always had: fields, types, enums, associations and constraints defined in your database and ActiveRecord models. **Apiwork builds on what has been there all along**, making Rails’ existing metadata fully available to the API layer instead of forcing you to redefine it by hand. This removes duplication and keeps the API aligned with the domain automatically as the application grows.

## Why Contracts?

Ruby’s dynamic nature works well inside a Rails application because the framework provides strong conventions and predictable patterns. This makes explicit types less necessary internally. But once data leaves the Rails environment and is consumed by TypeScript, Swift or Kotlin, those conventions disappear. External clients need clear and stable definitions of the data they work with.

Contracts make the API boundary explicit without turning Ruby into a statically typed language. Rails remains flexible internally, while the API surface becomes reliable and well-defined.

## Why Schemas?

Schemas describe the shape of your data model. Apiwork uses the metadata already present in ActiveRecord — columns, types, enums, associations and constraints — to build a consistent representation of your domain. This eliminates the need to define the same model information again in contracts, serializers or client-side types.

## Works With Rails

Apiwork doesn’t replace Rails. It prepares incoming data so Rails can handle it naturally:

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end
```

`contract.body[:invoice]` is validated, coerced and mapped into the structure ActiveRecord expects, including nested associations (`lines` → `lines_attributes`). Rails still manages persistence, callbacks and business logic. Apiwork simply ensures the data entering those layers is clean, structured and consistent.
