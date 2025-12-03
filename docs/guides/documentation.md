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
    summary "Invoice management"
    description "Create, update, and query invoices"
    tags :billing
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

Document individual actions in Contracts. See [Contracts: Actions](../core/contracts/actions.md#metadata) for the full reference.

```ruby
class InvoiceContract < Apiwork::Contract::Base
  action :index do
    summary "List all invoices"
    description "Returns invoices for the authenticated account"
    tags :billing
  end

  action :create do
    summary "Create invoice"
    description "Creates a new invoice. Returns 201 on success."
    operation_id "createInvoice"

    error_codes :unprocessable_entity
  end

  action :destroy do
    summary "Delete invoice"
    deprecated true
  end
end
```

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

## Generated Output

These documentation fields are used by the spec generators. See [Spec Generation](../core/spec-generation/openapi.md) for how to generate OpenAPI specs, TypeScript definitions, and other outputs.

## Internationalization

Action metadata — summaries and descriptions — can be translated. Define them in locale files instead of inline, and they'll change with `I18n.locale`.

See [i18n: Action Metadata](../advanced/i18n.md#action-metadata) for the full guide.
