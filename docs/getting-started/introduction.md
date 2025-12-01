---
order: 1
---

# Introduction

Apiwork is built around a simple idea: everything that enters or leaves your API should pass through a contract. A contract defines the exact shape of a request and the exact shape of a response. If the incoming data doesn't match, Apiwork rejects it early. If the outgoing data doesn't match, Apiwork notifies you during development. This creates a predictable and transparent API surface that is easy to understand and easy to rely on.

An API is a boundary between systems, and clear boundaries benefit from clear structure. Apiwork focuses entirely on this boundary layer. It steps in just before your controller runs to prepare clean, validated input, and steps in again immediately after the controller returns to shape the output. Everything inside that boundary — your models, callbacks and domain logic — remains fully Rails. Apiwork does not change how Rails works; it builds on it.

Using contracts brings practical advantages. Input is validated before reaching your models, the API becomes easier to reason about, and the contract itself becomes a single source of truth. From that one definition, Apiwork can generate OpenAPI documentation, Zod schemas and TypeScript types — which can be used to build fully typed client libraries with almost no extra work.

Apiwork provides a simple yet expressive DSL for defining types and enums directly inside your contracts:

```ruby
type :line do
  param :id, type: :uuid
  param :description, type: :string
  param :quantity, type: :integer
  param :price, type: :decimal
end
```

Writing contracts by hand works well and gives you full control. But Apiwork also takes this further with optional schemas:

```ruby
class LineSchema < Apiwork::Schema::Base
  attribute :id
  attribute :description, writable: true
  attribute :quantity,    writable: true
  attribute :price,       writable: true
end
```

A schema describes the shape of your domain and automatically inherits what Rails already knows — column types, enums, associations, nullability and constraints. When a contract is backed by a schema, Apiwork can infer much of the contract automatically and keep it aligned with the underlying data model all the way down to the database. It delivers the advantages of modern, schema-driven API systems while staying fully in tune with Rails' familiar conventions.

When a schema is present, Apiwork can also offer a unified approach to filtering, sorting, pagination, includes and intelligent preloading. These follow clear conventions and reasonable assumptions that fit naturally into most Rails applications. Enabling them is simple: you mark the fields you want to filter or sort on, and Apiwork takes care of the rest — even across nested and related data structures. The defaults serve almost every application, and you can override or extend anything when needed.

This behavior is powered by Apiwork's execution model and adapter system. The default adapter provides a Rails-friendly set of conventions, but everything is designed to be customizable. You can override parts of the adapter or replace it entirely with your own implementation. Most applications never need to, but the flexibility is there by design.

You still write your own controllers. You still use ActiveRecord the way you always have. Apiwork simply takes responsibility for the boundary: it ensures that data entering your controllers and data returning from them follows a consistent, well-defined structure. Rails remains Rails — and Apiwork enhances it by giving the API layer the clarity and structure it naturally lacks.

In practice, this creates a workflow that feels effortless. Rails continues to handle persistence, validations, callbacks and business logic. You continue to write controllers as you always have. Apiwork keeps the API, the documentation and the client-side types aligned automatically, all from definitions you write once and reuse across the entire system. It supports the way Rails developers like to work — by embracing conventions, reducing duplication and letting you focus on what truly matters.

## Works With Rails

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end
```

`contract.body[:invoice]` is validated, coerced and mapped into the structure ActiveRecord expects, including nested associations (`lines` → `lines_attributes`). Rails still manages persistence, callbacks and business logic. Apiwork simply ensures the data entering those layers is clean, structured and consistent.
