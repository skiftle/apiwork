---
order: 5
---

# Controllers

Controllers in Apiwork are thin. They connect the router to the domain and back.

A standard Rails controller with `Apiwork::Controller` included gets three things:

- `contract` — validated request parameters
- `expose` — serialized response
- `context` — data passed to representations

```ruby
class InvoicesController < ApplicationController
  include Apiwork::Controller

  def index
    expose Invoice.all
  end

  def show
    expose Invoice.find(params[:id])
  end

  def create
    invoice = Invoice.create(contract.body[:invoice])
    expose invoice
  end
end
```

The controller does not handle serialization, validation, or error formatting. It calls `expose` and the adapter handles the rest.

## Setup

`include Apiwork::Controller` adds everything a controller needs. Include it in a base controller for the API:

```ruby
class V1Controller < ApplicationController
  include Apiwork::Controller
end
```

This sets up:

- `before_action :validate_contract` — validates requests against the [contract](../contracts/) before the action runs
- `wrap_parameters false` — disables Rails parameter wrapping
- `rescue_from ConstraintError` — catches contract violations and renders structured errors

API controllers inherit from the base:

```ruby
class V1::InvoicesController < V1Controller
  def show
    expose Invoice.find(params[:id])
  end
end
```

The base controller is also where shared [error handling](#rescue_from) and [context](./context.md) belong.

## Contract Access

`contract` provides parsed, validated, type-coerced request data:

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  expose invoice
end

def index
  scope = Invoice.where(status: contract.query[:status]) if contract.query[:status]
  expose scope || Invoice.all
end
```

`contract.body` contains the request body. `contract.query` contains query parameters. Both return only params declared in the [contract](../contracts/).

Undeclared params are rejected before the action runs.

### Route Parameters

Route parameters like `:id` come from the Rails router, not the contract. Use `params` directly:

```ruby
def show
  invoice = Invoice.find(params[:id])
  expose invoice
end

def update
  invoice = Invoice.find(params[:id])
  invoice.update(contract.body[:invoice])
  expose invoice
end
```

`params[:id]` from the route, `contract.body` from the request body. Route parameters are handled by Rails routing, not the contract.

## Error Handling

`expose_error` renders transport-level errors:

```ruby
def show
  invoice = Invoice.find_by(id: params[:id])
  return expose_error :not_found unless invoice
  expose invoice
end
```

```ruby
expose_error :forbidden
expose_error :conflict, detail: "Order already shipped"
expose_error :unauthorized, meta: { reason: "token_expired" }
```

See [HTTP Errors](../errors/http-errors.md) for the full list of error codes and custom registration.

### rescue_from

Apiwork rescues `ConstraintError` (contract violations) automatically. Other exceptions need `rescue_from`:

```ruby
class V1Controller < ApplicationController
  include Apiwork::Controller

  rescue_from ActiveRecord::RecordNotFound do
    expose_error :not_found
  end

  rescue_from Pundit::NotAuthorizedError do
    expose_error :forbidden
  end
end
```

Controllers inherit from the base:

```ruby
class V1::InvoicesController < V1Controller
  def show
    invoice = Invoice.find(params[:id])
    expose invoice
  end
end
```

`Invoice.find` raises `RecordNotFound` if the record does not exist. The base controller catches it and returns a structured 404. No `find_by` + `nil` check needed.

## Skip Validation

`skip_contract_validation!` disables contract validation for specific actions:

```ruby
skip_contract_validation! only: [:ping, :health]
skip_contract_validation! except: [:create, :update]
```

::: warning
Use sparingly. Actions without contract validation lose request validation, typed parameters, and export coverage. The endpoint becomes invisible to introspection and exports.

If an endpoint has no contract, it probably does not belong inside the API boundary. Place it as a regular Rails route instead:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get '/health', to: 'status#ping'
  post '/webhooks/stripe', to: 'webhooks#stripe'

  mount Apiwork => '/'
end
```

These routes use standard Rails controllers without `Apiwork::Controller`. No contract, no adapter, no exports — because they are not part of the API.

`skip_contract_validation!` exists for the rare case where an action must live under the same API path but does not need a contract.
:::

## Automatic Behaviors

Three things happen automatically when `Apiwork::Controller` is included:

**Contract validation** — Every action is validated against its contract before execution. Invalid requests receive a 400 response with structured [contract errors](../errors/contract-errors.md).

**Parameter wrapping disabled** — Rails wraps JSON request bodies by default. Apiwork disables this because contracts define the expected shape explicitly.

**Constraint error rescue** — `ConstraintError` exceptions (raised by contract validation) are caught and rendered as structured error responses.

## Next Steps

- [Expose](./expose.md) — response serialization, meta, status codes
- [Context](./context.md) — passing data to representations

#### See also

- [Controller reference](../../reference/controller.md) — all controller methods and options
- [Contracts](../contracts/) — defining request and response shapes
- [HTTP Errors](../errors/http-errors.md) — error codes and custom registration
- [Serialization](../adapters/standard-adapter/serialization.md) — how the adapter serializes responses
