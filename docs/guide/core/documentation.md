---
order: 3
---

# Documentation

Your API definition can include documentation at every level — from the API itself down to individual attributes. These fields are picked up by generators to produce OpenAPI specs, TypeScript definitions, and other outputs.

```ruby
Apiwork::API.define '/api/v1' do
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
Apiwork::API.define '/api/v1' do
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

Mark an API as deprecated:

```ruby
info do
  deprecated true  # Shows deprecation warning in docs
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

Document individual actions in Contracts. [Contracts: Actions](../core/contracts/actions.md#metadata) covers `summary`, `description`, `tags`, `operation_id`, `deprecated`, and error responses.

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

    raises :unprocessable_entity
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

When using `schema!`, these fields are carried over to the auto-generated types — filters, payloads, and response schemas all inherit the attribute documentation.

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
Apiwork::API.define '/api/v1' do
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

### Param-Level Documentation

Document individual params within a type:

```ruby
type :address do
  param :street, type: :string, description: "Street address including number"
  param :city, type: :string, description: "City name"
  param :postal_code, type: :string, description: "ZIP or postal code", example: "12345"
end
```

## Enum Documentation

Document enums at definition:

```ruby
Apiwork::API.define '/api/v1' do
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

## Documenting Auto-Generated Types

When using `schema!`, adapters may generate types automatically. You can add documentation to these types directly in your Contract.

The built-in Apiwork adapter generates types for filters, sorts, and payloads. For example, an `InvoiceContract` with `schema!` gets `invoice_filter`, `invoice_sort`, `invoice_create_payload`, and `invoice_update_payload` types.

### Adding Type Description

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  type :filter, description: "Filter invoices by any combination of fields"
  type :sort, description: "Sort invoices by date or amount"
  type :create_payload, description: "Data for creating a new invoice"
end
```

::: info Scoped Names
When referencing types in a Contract, use the short name without the prefix. Write `type :filter`, not `type :invoice_filter`. The Contract automatically scopes types to the resource — `:filter` becomes `invoice_filter` in the generated output.
:::

### Adding Param Description

Document individual params within a type:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  type :filter do
    param :status, description: "Filter by invoice status"
    param :amount, description: "Filter by amount range"
  end
end
```

### Adding Custom Params

Extend generated types with new fields:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  type :filter do
    param :search, type: :string, description: "Full-text search across all fields"
  end
end
```

### Documenting Enums

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  enum :status, description: "Invoice lifecycle status"
end
```

These declarations merge with the auto-generated definitions. [Type Merging](../core/type-system/type-merging.md) explains how to add params to generated types without replacing them.

## Generated Output

These documentation fields appear in generated specs. [Spec Generation](../core/spec-generation/openapi.md) covers how to generate OpenAPI, TypeScript, and Zod output.

## Internationalization

Action metadata — summaries and descriptions — can be translated. Define them in locale files instead of inline, and they'll change with `I18n.locale`.

[i18n: Action Metadata](../advanced/i18n.md#action-metadata) shows how to set up locale files for action summaries and descriptions.

Type and enum descriptions can also be translated. [i18n: Type Descriptions](../advanced/i18n.md#type-descriptions) covers the lookup keys.

For complex cases where you need to extend auto-generated types, [Type Merging](../core/type-system/type-merging.md) explains how to add custom params without replacing the generated definition.

## Examples

- [API Documentation](/examples/api-documentation.md) — Complete example of documenting an API
- [API Documentation i18n](/examples/api-documentation-i18n.md) — Multilingual documentation with locale files
