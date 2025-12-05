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

<!-- example: funny-snake -->

<<< @/app/app/contracts/funny_snake/invoice_contract.rb

<details>
<summary>Introspection</summary>

<<< @/examples/funny-snake/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/funny-snake/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/funny-snake/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/funny-snake/openapi.yml

</details>

Request doesn't match? Rejected immediately. Response doesn't match? Logged in development so you catch it early.

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

Add `schema!` to your contract, and Apiwork generates everything — request bodies, response shapes, filter types, sort options:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

<details>
<summary>Introspection</summary>

<<< @/examples/eager-lion/introspection.json

</details>

<details>
<summary>TypeScript</summary>

<<< @/examples/eager-lion/typescript.ts

</details>

<details>
<summary>Zod</summary>

<<< @/examples/eager-lion/zod.ts

</details>

<details>
<summary>OpenAPI</summary>

<<< @/examples/eager-lion/openapi.yml

</details>

The adapter reads your database and model to infer:

- Column types
- Enum values
- Nullability
- Associations
- Default values

You declare what to expose. Apiwork figures out the rest.

## One Metadata Model

API definitions, contracts, and schemas all feed into the same metadata. That's why generated specs stay perfectly aligned with your server — OpenAPI, TypeScript, Zod all come from the same source.

Change a type, and the TypeScript updates. Add a filter, and OpenAPI reflects it. One source of truth, multiple outputs.

## Next Steps

- [Quick Start](./quick-start.md) — build a complete endpoint from scratch
- [Execution Layer](./execution-layer.md) — filtering, sorting, pagination, and eager loading
