---
order: 4
---

# Core Concepts

Apiwork is built around three main ideas: API definitions, contracts,
and schemas. Each plays a different role, but together they describe the
shape and behaviour of your API.

## API Definition

Every Apiwork API begins with a definition file in `config/apis/`. It
lives alongside `routes.rb`: under the hood Apiwork still uses the Rails
router and regular controllers, but the API definition lets you describe
your API in a more structured, API-focused way.

```ruby
# config/apis/api_v1.rb
Apiwork::API.draw '/api/v1' do
  resources :invoices do
    resource :payments
  end
end
```

This defines which resources exist and which actions they expose.
Internally, Apiwork uses the Rails router, so `resources` behaves
exactly as you'd expect.

Every resource is expected to have a contract. If a request reaches a
resource without one, Apiwork raises an error.

## Contracts

A contract describes what each action accepts and what it returns. It
defines the shape both sides must follow.

```ruby
# app/contracts/api/v1/invoice_contract.rb
module Api
  module V1
    class InvoiceContract < ApplicationContract
      type :invoice do
        param :id, type: :uuid
        param :created_at, type: :datetime
        param :updated_at, type: :datetime
        param :number, type: :string
        param :status, type: :string, enum: %w[draft, sent, due, paid]
      end

      action :index do
        request do
          query do
            param filter, type: :object do
              param :number, type: :string
            end
            param :sort, type: :string
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
  end
end
```

If a request doesn't match the contract, it's rejected before hitting
your controller.\
If a response doesn't match, Apiwork logs it in development so you can
catch it early.

See the [Manual Contract Example](../examples/manual-contract.md) for a
full contract covering every action.

## Controllers

Controllers remain familiar. The only changes are:

- use `contract.query` and `contract.body` instead of `params`
- return data with `respond_with` and errors with `respond_with_error`

```ruby
# app/controllers/api/v1/invoices_controller.rb
module Api
  module V1
    class InvoicesController < ApplicationController
      before_action :set_invoice, only: %i[show update destroy]

      def index
        invoices = Invoice.query(contract.query)
        respond invoices
      end

      def show
        respond invoice
      end

      def create
        invoice = Invoice.create(contract.body[:invoice])
        respond invoice
      end

      def update
        invoice.update(contract.body[:invoice])
        respond invoice
      end

      def destroy
        invoice.destroy
        respond invoice
      end

      private

      attr_reader :invoice

      def set_invoice
        @invoice = Invoice.find(params[:id])
      end
    end
  end
end
```

::: info
`contract.query` and `contract.body` effectively replace Strong Parameters. They contain only the fields defined in the contract, and anything unknown is filtered out before your controller runs. That means you can pass them straight into `create` and `update` without any additional permitting.
:::

## Schemas

Schemas connect your API to your models. They're optional, but they
remove most of the manual work involved in defining contracts.

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

Add `schema!` to your contract and Apiwork's built-in adapter activates:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

From your schema, Apiwork can derive everything the contract needs:

- **Filter types** --- from `filterable: true`
- **Sort types** --- from `sortable: true`
- **Writable payloads** --- from `writable: true`
- **Includes** --- from associations
- **Response shapes** --- from all attributes

These generated types drive request validation and also power
TypeScript, Zod, and OpenAPI generation --- all from the same source.

The adapter also reads your models and database to infer column types,
enum values, nullability, associations, and defaults. You decide what to
expose; Apiwork fills in the rest.

See the [Schema-Driven Example](../examples/schema-driven-contract.md)
to view the full generated output.

## One Metadata Model

API definitions, contracts, and schemas all contribute to the same
metadata. This is why generated output --- OpenAPI, TypeScript, Zod, and
more --- always stays aligned with what your server actually does.

Change something once, and everything updates consistently.

## Next Steps

- [Quick Start](./quick-start.md) --- build a complete endpoint from
  scratch\
- [Execution Layer](./execution-layer.md) --- filtering, sorting,
  pagination, and eager loading
