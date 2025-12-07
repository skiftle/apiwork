---
order: 3
---

# Core Concepts

Apiwork has three main pieces: API definitions, contracts, and schemas. Here's how they fit together.

## API Definition

Your API starts with a definition file in `config/apis/`. Think of it like `routes.rb`, but for your API structure:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :invoices do
    member do
      patch :archive
    end
  end
end
```

This declares which resources exist and which actions they support. Under the hood, Apiwork uses the Rails router — `resources` works exactly as you'd expect.

The difference: every resource needs a contract. No contract, no endpoint.

## Contracts

Contracts define what each action accepts and returns:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  type :invoice do
    param :id, type: :uuid
    param :number, type: :string
    param :status, type: :string
  end

  action :index do
    response do
      body { param :invoices, type: :array, of: :invoice }
    end
  end

  action :show do
    response do
      body { param :invoice, type: :invoice }
    end
  end
end
```

Request doesn't match? Rejected immediately. Response doesn't match? Logged in development so you catch it early.

See [Manual Contract Example](../examples/manual-contract.md) for a complete contract with all actions.

## Controllers

Your controllers stay familiar. Two changes:

- Use `contract.query` and `contract.body` instead of `params`
- Use `respond_with` to serialize responses

::: info Replaces Strong Parameters
`contract.query` and `contract.body` only include params defined in the contract. Unknown keys are rejected before your controller runs. Pass them directly to `create` and `update` — no `permit` needed.
:::

```ruby
before_action :set_invoice, only: %i[show update destroy archive]

def index
  invoices = Invoice.query(contract.query)
  respond_with invoices
end

def show
  respond_with invoice
end

def create
  invoice = Invoice.create(contract.body[:invoice])
  respond_with invoice
end

def update
  invoice.update(contract.body[:invoice])
  respond_with invoice
end

def destroy
  invoice.destroy
  respond_with invoice
end

def archive
  invoice.archive
  respond_with invoice
end

private

attr_reader :invoice

def set_invoice
  @invoice = Invoice.find(params[:id])
end
```

Same controller patterns. Apiwork just guarantees the data matches the contract.

## Schemas

Schemas connect contracts to your models. They're optional, but they save you from writing most contract definitions by hand.

<!-- example: eager-lion -->

```ruby
# app/schemas/line_schema.rb
class LineSchema < Apiwork::Schema::Base
  attribute :id
  attribute :description, writable: true
  attribute :quantity, writable: true
  attribute :price, writable: true
end

# app/schemas/invoice_schema.rb
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
  attribute :number, writable: true, filterable: true
  attribute :issued_on, writable: true, sortable: true
  attribute :notes, writable: true
  attribute :status, filterable: true, sortable: true

  has_many :lines, writable: true, include: :always
  belongs_to :customer, include: :always
end
```

Add `schema!` to your contract:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

This single line activates Apiwork's [built-in adapter](../core/runtime/introduction.md). The adapter reads your schema and generates everything the contract needs:

- **Filter types** — from `filterable: true` attributes
- **Sort types** — from `sortable: true` attributes
- **Payload types** — from `writable: true` attributes
- **Include types** — from associations
- **Response types** — from all attributes

These generated types power request validation, TypeScript generation, Zod schemas, and OpenAPI specs — all from the same source.

The adapter also reads your database and model to infer column types, enum values, nullability, associations, and defaults. You declare what to expose — Apiwork figures out the rest.

See [Schema-Driven Example](../examples/schema-driven-contract.md) for complete generated output.

## One Metadata Model

API definitions, contracts, and schemas all feed into the same metadata. That's why generated specs stay perfectly aligned with your server — OpenAPI, TypeScript, Zod all come from the same source.

Change a type, and the TypeScript updates. Add a filter, and OpenAPI reflects it. One source of truth, multiple outputs.

## Next Steps

- [Quick Start](./quick-start.md) — build a complete endpoint from scratch
- [Execution Layer](./execution-layer.md) — filtering, sorting, pagination, and eager loading
