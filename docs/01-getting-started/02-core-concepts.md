# Core Concepts

Apiwork is built around three core pieces: the API definition, the contracts, and (optionally) schemas. Together they describe how your API is structured, which resources exist, which actions they expose, and what every request and response must look like.

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

A contract defines the actions a resource offers — such as `index`, `show`, `create` — and the exact structure of both the incoming request and the outgoing response. Contracts may also define custom types or enums used across multiple actions.

```ruby
# app/contracts/invoice_contract.rb
class InvoiceContract < Apiwork::Contract::Base
  type :line do
    param :description, type: :string
    param :quantity,    type: :integer
    param :price,       type: :decimal
  end

  action :index do
    request do
      query do
        param :status, type: :string
      end
    end
  end

  action :show

  action :create do
    request do
      body do
        param :invoice, type: :object, required: true do
          param :number,    type: :string
          param :issued_on, type: :date
          param :notes,     type: :string
          param :lines,     type: :array, of: :line
        end
      end
    end

    response do
      body do
        param :id,         type: :uuid
        param :number,     type: :string
        param :issued_on,  type: :date
        param :created_at, type: :datetime
      end
    end
  end
end
```

If an incoming request does not match the contract, Apiwork returns an error. If an outgoing response does not match the contract, Apiwork logs the mismatch in development mode.

## Controllers

Your controllers remain almost the same. You keep your own logic and your own actions. The only difference is:

- Request input comes from `contract.query` or `contract.body` rather than params
- All output is sent through `respond_with`

```ruby
# app/controllers/invoices_controller.rb
def index
  invoices = Invoice.where(status: contract.query[:status])
  respond_with invoices
end

def show
  invoice = Invoice.find(params[:id])
  respond_with invoice
end

def create
  invoice = Invoice.create!(contract.body[:invoice])
  respond_with invoice
end
```

Other than that, Apiwork does not change how your controllers work; it simply guarantees that whatever enters or leaves the controller matches the contract.

## Schemas

Schemas are optional but eliminate most manual contract definitions. They map directly to your ActiveRecord models.

```ruby
# app/schemas/line_schema.rb
class LineSchema < Apiwork::Schema::Base
  attribute :id
  attribute :description, writable: true
  attribute :quantity,    writable: true
  attribute :price,       writable: true
end

# app/schemas/invoice_schema.rb
class InvoiceSchema < Apiwork::Schema::Base
  attribute :id
  attribute :number,     writable: true, filterable: true
  attribute :issued_on,  writable: true, sortable: true
  attribute :notes,      writable: true
  attribute :status,     filterable: true, sortable: true
  attribute :created_at, sortable: true
  attribute :updated_at

  has_many :lines, writable: true, include: :always
  belongs_to :customer, include: :always
end
```

With `schema!` in your contract, Apiwork auto-generates request bodies, response shapes, filter types, sort options and includes — all from this single declaration:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!
end
```

Schemas are processed through **adapters**, which turn schema definitions into actionable metadata used for filtering, sorting, pagination, eager loading and nested operations.

Apiwork ships with a built-in adapter tightly integrated with ActiveRecord. It automatically inherits:

- Database column types
- Enums
- Nullability
- Relational structure

This allows Apiwork to infer capabilities directly from the underlying model.

## One Metadata Model

The API definition, contracts and schemas all feed into a single metadata model. Because everything is defined once and in one place, Apiwork can automatically generate OpenAPI, Zod and TypeScript definitions that stay perfectly in sync with the server.

This means documentation, typed clients and server behaviour all come from the same source of truth, eliminating duplication and keeping the entire API consistent end-to-end.
