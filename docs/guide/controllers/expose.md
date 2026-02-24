---
order: 1
---

# Expose

`expose` returns data from an Apiwork controller. It serializes records through the [representation](../representations/), applies adapter behavior, and renders the response.

## Usage

```ruby
def show
  invoice = Invoice.find(params[:id])
  expose invoice
end
```

For collections:

```ruby
def index
  expose Invoice.all
end
```

The adapter determines what happens next — serialization, eager loading, pagination, and key transformation are handled automatically.

## Meta

Pass metadata alongside the response:

```ruby
def index
  invoices = Invoice.all
  expose invoices, meta: { total: invoices.count }
end
```

The adapter merges `meta` into the response. For collections with pagination, the adapter adds pagination metadata automatically.

### Typed Meta

By default, `meta` is an untyped optional object. To give it a shape — visible in exports and validated in development — extend the response in the contract:

```ruby
class InvoiceContract < ApplicationContract
  representation InvoiceRepresentation

  action :index do
    response do
      body do
        object :meta do
          integer :total
          integer :filtered
        end
      end
    end
  end
end
```

The typed `meta` shape appears in OpenAPI, TypeScript, and Zod exports. The controller passes the values at runtime:

```ruby
def index
  invoices = Invoice.where(filter_params)
  expose invoices, meta: { total: Invoice.count, filtered: invoices.count }
end
```

## Status

`expose` defaults to `:ok` (200) for all actions except `create`, which defaults to `:created` (201).

Override with `status:`:

```ruby
def accept
  order.accept!
  expose order, status: :accepted
end
```

## No Content

When the contract declares `no_content!`, `expose` returns 204 with an empty body:

```ruby
class InvoiceContract < ApplicationContract
  action :destroy do
    response { no_content! }
  end
end
```

```ruby
def destroy
  Invoice.find(params[:id]).destroy
  expose nil
end
```

## Error Detection

When using the [standard adapter](../adapters/standard-adapter/), `expose` checks for validation errors on the record. If the record has errors, the adapter converts them to a 422 response with structured [domain errors](../errors/domain-errors.md).

```ruby
def create
  invoice = Invoice.create(contract.body[:invoice])
  expose invoice
end
```

If `Invoice.create` fails validation, `expose` returns:

```json
{
  "layer": "domain",
  "issues": [
    {
      "code": "required",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": {}
    }
  ]
}
```

The adapter handles both success and failure automatically.

See [Validation](../adapters/standard-adapter/validation.md) for the full error mapping.

## Without Representation

When the contract has no linked representation, `expose` renders data as-is with key transformation:

```ruby
def status
  expose({ version: "1.0", uptime: process_uptime })
end
```

## Response Validation

In development, `expose` validates the response against the contract and logs warnings for mismatches. This catches shape drift between the representation and the contract definition.

#### See also

- [Controller reference](../../reference/controller.md) — `expose` method details
- [Serialization](../adapters/standard-adapter/serialization.md) — how the adapter serializes responses
- [Validation](../adapters/standard-adapter/validation.md) — domain error handling
- [HTTP Errors](../errors/http-errors.md) — transport-level errors via `expose_error`
