---
order: 1
---
# Introduction

Modern clients expect typed APIs — TypeScript frontends, OpenAPI documentation, validated request shapes.

Rails is productive. Ruby is expressive. You don't want to give that up. But Ruby does not naturally produce typed boundaries — so you keep them in sync manually.

You add a column, and now the serializer, the validator, the OpenAPI spec, and the TypeScript types all need updating. Miss one, and they drift. You duplicate knowledge — once in Ruby, once in JSON schemas, once in TypeScript.

Apiwork exists so you don't have to leave Rails to get typed APIs. ActiveRecord, migrations, associations, validations, gems — none of it changes.

You describe your domain once. Apiwork maps every Rails concept to its typed equivalent — enums to typed enums, STI and polymorphic associations to discriminated unions, columns and nullability to typed fields — and builds the full boundary: validation, serialization, filtering, sorting, pagination, nested writes, and typed exports.

What validates requests in production is what generates your OpenAPI, TypeScript, and Zod. Nothing drifts.

## Define Your Domain

A representation describes how a model appears through the API:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :number, writable: true, filterable: true, sortable: true
  attribute :status, filterable: true
  attribute :issued_on, writable: true, sortable: true

  belongs_to :customer, filterable: true
  has_many :lines, writable: true
end
```

Types, nullability, and enums are detected from the database. You declare intent — `writable`, `filterable`, `sortable` — and Apiwork builds everything else. Add a column, and the contract, query parameters, and exports all update together.

## What You Get

From this representation, Apiwork generates:

- **Request validation** — payloads are typed and checked before the controller runs
- **Response serialization** — records are returned with the right attributes and associations
- **Filtering** — `?filter[status][eq]=sent` with typed operators
- **Sorting** — `?sort[issued_on]=desc`
- **Pagination** — offset or cursor-based
- **Nested writes** — create or update related records in one request
- **OpenAPI, TypeScript, Zod** — generated from the same definitions that run in production

The controller stays thin:

```ruby
def index
  expose Invoice.all
end

def create
  expose Invoice.create(contract.body[:invoice])
end
```

`contract.body` has validated, typed parameters. `expose` serializes the response — and if the record has errors, they are returned as structured error responses automatically.

## How It Works

You write a representation. Apiwork builds contracts from it — typed rules that validate every request and shape every response at runtime. Adapters read those contracts and apply filtering, sorting, pagination, and nested writes. Exports read the same contracts and generate OpenAPI, TypeScript, and Zod.

One description flows through the entire stack. That's how nothing drifts.

Contracts can also be written by hand, without representations or ActiveRecord.

## The Philosophy

Rails is optimized for developer happiness. Apiwork protects that.

It makes the boundary explicit without forcing you into another ecosystem. It gives you typed contracts without abandoning Ruby. It lets the database shape the API instead of re-describing it manually.

Rails stays Rails. Apiwork makes the boundary deliberate.

## Next Steps

- [Installation](./installation.md) — add Apiwork to your Rails app
- [Quick Start](./quick-start.md) — build a complete API in 7 steps
- [Core Concepts](./core-concepts.md) — how the pieces fit together
