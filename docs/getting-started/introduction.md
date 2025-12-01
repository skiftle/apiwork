---
order: 1
---

# Introduction

Apiwork is built around a simple idea: everything that enters or leaves your API should pass through a contract. A contract defines the exact shape of a request and the exact shape of a response. If incoming data doesn’t match, Apiwork rejects it early; if outgoing data violates the contract, Apiwork alerts you during development.

An API is a boundary between systems, and clear boundaries benefit from clear structure. Apiwork focuses entirely on this boundary layer. It steps in just before your controller runs to prepare clean, validated input, and steps in again immediately after the controller returns to shape the output. Everything inside that boundary — your models, callbacks and domain logic — remains fully Rails. Apiwork does not change how Rails works; it builds on it.

Inside a Rails application, Ruby’s flexibility works in your favor — the framework’s conventions make explicit types feel unnecessary. But once data crosses the API boundary and ends up in a TypeScript, Swift or Kotlin client, those conventions disappear. Outside Rails, nothing guarantees the shape of your data unless the API defines it explicitly. Contracts give that clarity: they specify exactly what the API accepts and returns, validate incoming data before it touches your models, and ensure predictable, stable responses for any client. And because a contract serves as a single, authoritative definition, Apiwork can also generate OpenAPI specs, Zod schemas and TypeScript types from it — producing fully typed client libraries as a natural side effect.

At its core, Apiwork provides a powerful and expressive type system — a DSL for defining any shape your contracts might require:

```ruby
class InvoiceContract < Apiwork::Contract::Base

  enum :status, values: %w[draft sent due paid]

  type :invoice do
    param :id, type: :uuid, required: true
    param :created_at, type: :datetime, required: true
    param :updated_at, type: :datetime, required: true
    param :number, type: :string, required: true
    param :status, type: :status, required: true
    param :lines, type: :object, required: true do
      param :id, type: :uuid, required: true
      param :description, type: :string, required: true
      param :price, type: :decimal, required: true
      param :quantity, type: :integer, required: true
    end
  end

  action :index do
    request do
      query do
        param :filter, type: :object do
          param :status, type: :status
        end
      end
    end
    response do
      body do
        param :invoices, type: :array, of: :invoice
      end
    end
  end

  action :show do
    response do
      body do
        param :invoice, type: :invoice
      end
    end
  end
end
```

Writing contracts by hand works well and gives you full control, and if that were all Apiwork offered, it would already be a solid way to build an API. But Apiwork goes further. Instead of describing every field, type and rule yourself, you can connect a schema to a contract and let Apiwork generate most of the structure for you. The schema becomes the bridge between your model, your database, and your contract.

```ruby
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :number, writable: true, filterable: true
  attribute :created_at, sortable: true
  has_many  :lines, writable: true, include: :always
end

class InvoiceContract < Apiwork::Contract::Base
  schema!
end

```

When a schema is present, it begins with the knowledge Rails already has: column types, enums, associations, nullability and database constraints. This keeps your API aligned with the model itself without any duplicate definitions. And when something needs to change, you update it in the single source of truth — either directly in the schema, or in the model and database it reflects.

But that’s still only the beginning. Once a schema is attached to a contract — and by relying on a few sensible assumptions and familiar Rails conventions — Apiwork takes care of filtering, sorting, pagination, nested saves, includes and intelligent preloading of associations. You simply declare which fields are writable, filterable or sortable, and Apiwork handles the rest: resolving relationships, applying efficient preload strategies and ensuring that requests and responses share the same consistent structure.

This behaviour comes from Apiwork’s execution model and adapter system. The built-in adapter follows Rails’ conventions closely, but every part of it can be customised or replaced when your application needs something different. Nothing locks you in; you override only what matters, and Rails keeps doing what Rails does best.

You still write your own controllers. You still use ActiveRecord exactly as you always have. Apiwork simply standardises the boundary — the data going in and the data coming out — so your API stays coherent, validated and predictable. Rails remains the core engine of your application; Apiwork adds the structure and clarity the API layer has historically lacked.

And in practice, it feels completely natural. Rails continues to handle persistence, validations, callbacks and business logic, while Apiwork keeps your responses, documentation and client-side types aligned automatically. You define things once and reuse them everywhere, following conventions rather than repeating yourself.

That’s the design goal behind Apiwork — and its greatest strength:
it feels like Rails, because it is Rails.
