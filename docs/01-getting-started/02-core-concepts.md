# Core Concepts

Apiwork is built around three core pieces: the API definition, the contracts, and (optionally) schemas. Together they describe how your API is structured, which resources exist, which actions they expose, which types are used, and what every request and response must look like.

## API Definition

The API definition acts similarly to Rails' `routes.rb`, but focuses on API structure rather than URL routing alone. It defines the resource tree and ties each resource to its contract and controller.

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :invoices
end
```

Every `resources` entry behaves exactly like Rails' own `resources`. Apiwork uses the Rails router under the hood, but additionally requires a contract for each resource.

## Contracts

A contract defines the actions a resource offers - such as `index`, `show`, `create` - and the exact structure of both the incoming request and the outgoing response. Contracts may also define custom types or enums used across multiple actions.

```ruby
# app/contracts/api/v1/invoice_contract.rb
module Api
  module V1
    class InvoiceContract < V1Contract

      type :line_item do
        param :description, type: :string
        param :quantity,    type: :integer
        param :price,       type: :decimal
      end

      enum :sort_direction, values: %w[asc desc]

      action :index do
        request do
          query do
            param :sort, type: :sort_direction
          end
        end

        response do
          body do
            param :invoices, type: :array do
              param :id,     type: :uuid
              param :status, type: :string
            end
          end
        end
      end

      action :show do
        response do
          body do
            param :id,     type: :uuid
            param :status, type: :string
            param :items,  type: :array, of: :line_item
          end
        end
      end

      action :create do
        request do
          body do
            param :status, type: :string, required: true
            param :items,  type: :array, of: :line_item
          end
        end

        response do
          body do
            param :id,     type: :uuid
            param :status, type: :string
          end
        end
      end

    end
  end
end
```

If an incoming request does not match the contract, Apiwork returns an error. If an outgoing response does not match the contract, Apiwork logs the mismatch in development mode.

## Controllers

Your controllers remain almost the same. You keep your own logic and your own actions. The only difference is:

- request input comes from `contract.query` or `contract.body` rather than params.
- all output is sent through `respond_with`

```ruby
# app/controllers/api/v1/invoices_controller.rb
def index
  invoices = Invoice.order(status: contract.query[:sort])
  respond_with invoices
end

def show
  invoice = Invoice.find(params[:id])
  respond_with invoice
end

def create
  invoice = Invoice.create!(contract.body)
  respond_with invoice
end
```

Other than that Apiwork does not change your controllers work; it simply guarantees that whatever enters or leaves the controller matches the contract.

## Schemas (optional superpower)

Schemas are optional but extremely powerful. They resemble a modern, structured version of Active Model Serializers, but they do much more. Schemas are processed through **adapters**, which turn schema definitions into actionable metadata used for filtering, sorting, pagination, eager loading and nested operations.

Apiwork ships with a built-in adapter tightly integrated with ActiveRecord. It automatically inherits:

- database column types
- enums
- nullability
- relational structure

This allows Apiwork to infer capabilities directly from the underlying model. Developers may also implement **custom adapters** if they need to support other data sources or extend the mapping logic, but the built-in adapter is powerful enough for most applications.

Using schemas is not required - everything can be defined manually in contracts - but following a few Rails-like conventions unlocks a large amount of functionality automatically.

## One Metadata Model

The API definition, contracts and schemas all feed into a single metadata model. Because everything is defined once and in one place, Apiwork can automatically generate OpenAPI, Zod and TypeScript definitions that stay perfectly in sync with the server.

This means documentation, typed clients and server behaviour all come from the same source of truth, eliminating duplication and keeping the entire API consistent end-to-end.
