---
order: 3
---

# Documentation

Your API definition can include documentation at every level — from the API itself down to individual attributes. These fields are picked up by generators to produce OpenAPI specs, TypeScript definitions, and other outputs.

```ruby
Apiwork::API.draw '/api/v1' do
  info do
    title "Billing API"
    description "Manage invoices and payments"
  end

  resources :invoices do
    describe :create, summary: "Create a new invoice"
  end
end
```

## API-Level Documentation

The `info` block documents your entire API:

```ruby
Apiwork::API.draw '/api/v1' do
  info do
    title "Acme API"
    version "1.0.0"
    summary "The Acme REST API"
    description <<~MD
      Full documentation for the Acme API.

      Supports **markdown** formatting.
    MD

    terms_of_service "https://acme.com/terms"

    contact do
      name "API Team"
      email "api@acme.com"
      url "https://acme.com/support"
    end

    license do
      name "MIT"
      url "https://opensource.org/licenses/MIT"
    end

    server url: "https://api.acme.com", description: "Production"
    server url: "https://staging-api.acme.com", description: "Staging"
  end
end
```

### Info Fields

| Field | Description |
|-------|-------------|
| `title` | API name. Required for valid OpenAPI. |
| `version` | Semantic version string. |
| `summary` | One-line description. |
| `description` | Longer description. Supports markdown. |
| `terms_of_service` | URL to terms of service. |
| `contact` | Contact block with `name`, `email`, `url`. |
| `license` | License block with `name`, `url`. |
| `server` | Server URL and description. Call multiple times for multiple environments. |

### API Flags

Mark an API as deprecated or internal:

```ruby
info do
  deprecated true  # Shows deprecation warning in docs
  internal true    # Excludes from public documentation
end
```

### API Tags

Categorize your entire API:

```ruby
info do
  tags :billing, :payments, :invoicing
end
```

## Resource Documentation

Document resources with `summary`, `description`, and `tags`:

```ruby
resources :invoices do
  summary "Invoice management"
  description "Create, update, and query invoices"
  tags :billing
end
```

These appear in the OpenAPI spec under the resource's operations.

## Action Documentation

Use `describe` to document individual actions:

```ruby
resources :invoices do
  describe :index,
    summary: "List all invoices",
    description: "Returns invoices for the authenticated account"

  describe :show,
    summary: "Get invoice details"

  describe :create,
    summary: "Create invoice",
    description: "Creates a new invoice. Returns 201 on success.",
    tags: [:write]

  describe :destroy,
    summary: "Delete invoice",
    deprecated: true
end
```

### Action Fields

| Field | Description |
|-------|-------------|
| `summary` | One-line description. Shows in endpoint lists. |
| `description` | Longer description. Supports markdown. |
| `tags` | Action-specific tags (merged with resource tags). |
| `deprecated` | Marks the action as deprecated. |
| `operation_id` | Explicit operation ID for OpenAPI. |

### Operation IDs

By default, Apiwork generates operation IDs from the resource and action name (`invoices_create`). Override with `operation_id`:

```ruby
describe :create, operation_id: "createInvoice"
```

This affects the generated OpenAPI spec and TypeScript function names.

## Attribute Documentation

Document schema attributes inline:

```ruby
class InvoiceSchema < Apiwork::Schema
  attribute :number,
    description: "Unique invoice number",
    example: "INV-2024-001"

  attribute :email,
    description: "Customer email address",
    example: "customer@example.com",
    format: :email

  attribute :issued_at,
    description: "When the invoice was issued",
    format: :date_time

  attribute :legacy_field,
    description: "Use 'new_field' instead",
    deprecated: true
end
```

### Attribute Documentation Fields

| Field | Description |
|-------|-------------|
| `description` | What this attribute represents. |
| `example` | Example value for documentation. |
| `format` | OpenAPI format hint. For strings: `:email`, `:uuid`, `:uri`, `:url`, `:date`, `:date_time`. |
| `deprecated` | Marks the attribute as deprecated. |

The `format` field helps both documentation tools and client generators understand the data:

```ruby
attribute :website, format: :uri
attribute :created_at, format: :date_time
attribute :id, format: :uuid
```

## Type Documentation

Document custom types when you define them:

```ruby
Apiwork::API.draw '/api/v1' do
  type :money,
    description: "A monetary amount with currency",
    example: { amount: "99.99", currency: "USD" } do
    param :amount, type: :decimal
    param :currency, type: :string
  end

  type :address,
    description: "Physical mailing address" do
    param :street, type: :string
    param :city, type: :string
    param :postal_code, type: :string
    param :country, type: :string
  end
end
```

## Enum Documentation

Document enums at definition:

```ruby
Apiwork::API.draw '/api/v1' do
  enum :invoice_status,
    values: [:draft, :sent, :paid, :void],
    description: "Current state of an invoice",
    example: :sent

  enum :payment_method,
    values: [:card, :bank_transfer, :cash],
    description: "How the customer pays",
    deprecated: true  # Use payment_type instead
end
```

## How Generators Use Documentation

### OpenAPI

The OpenAPI generator maps documentation fields to the spec:

- `info` block → `info` object
- Resource `summary`/`description` → operation descriptions
- `describe` → path operation fields
- Attribute `description`/`example`/`format` → schema properties
- `deprecated` → `deprecated: true` throughout

Generate with:

```bash
rake apiwork:spec:write FORMAT=openapi OUTPUT=public/openapi.json
```

### TypeScript

The TypeScript generator uses documentation for JSDoc comments:

```typescript
/**
 * A monetary amount with currency
 * @example { amount: "99.99", currency: "USD" }
 */
interface Money {
  amount: string;
  currency: string;
}

/**
 * Current state of an invoice
 */
type InvoiceStatus = 'draft' | 'sent' | 'paid' | 'void';
```

Generate with:

```bash
rake apiwork:spec:write FORMAT=typescript OUTPUT=public/types.ts
```

## Future: Internationalization

Apiwork will support translated documentation in a future release. The vision:

```ruby
# config/locales/api.en.yml
en:
  apiwork:
    schemas:
      invoice:
        number:
          description: "Unique invoice number"

# config/locales/api.sv.yml
sv:
  apiwork:
    schemas:
      invoice:
        number:
          description: "Unikt fakturanummer"
```

For now, write documentation in your primary language. The i18n feature will be backwards-compatible when released.
