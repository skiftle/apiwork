---
order: 6
---

# Metadata

Metadata describes the API for documentation and export generation.

## Info

```ruby
Apiwork::API.define '/api/v1' do
  info do
    title 'My API'
    version '1.0.0'
    description 'Public API for my application'
  end
end
```

Available options:

```ruby
info do
  title 'My API'
  version '1.0.0'
  description 'Full description'
  summary 'Short summary'
  deprecated!
  terms_of_service 'https://example.com/tos'

  contact do
    name 'API Support'
    email 'api@example.com'
    url 'https://example.com/support'
  end

  license do
    name 'MIT'
    url 'https://opensource.org/licenses/MIT'
  end

  server do
    url 'https://api.example.com'
    description 'Production'
  end
  server do
    url 'https://staging-api.example.com'
    description 'Staging'
  end

  tags 'Posts', 'Comments', 'Users'
end
```

## Translations

Metadata can be defined in translation files instead of code. Apiwork derives a locale key from the API's base path (`/api/v1` becomes `api/v1`) and looks up translations under `apiwork.apis.<locale_key>`:

```yaml
# config/locales/en.yml
en:
  apiwork:
    apis:
      api/v1:
        info:
          title: Billing API
          description: API for managing invoices and payments
        contracts:
          invoice:
            actions:
              index:
                summary: List invoices
                description: Returns a paginated list of invoices
              create:
                summary: Create an invoice
        representations:
          invoice:
            attributes:
              number:
                description: Unique invoice number
              status:
                description: Current invoice lifecycle status
            associations:
              customer:
                description: The customer this invoice belongs to
        types:
          address:
            description: A postal address
        enums:
          invoice_status:
            description: Invoice lifecycle states
```

Values defined in code take precedence. Translations fill in what code does not define.

Pass `locale:` to [introspection](../introspection/api-introspection.md) and [exports](../exports/) to generate output in a specific locale:

```ruby
Apiwork::API.introspect('/api/v1', locale: :sv)
Apiwork::Export.generate(:openapi, '/api/v1', locale: :sv)
```

Error message translations are covered in [Validation — Translating Custom Codes](../adapters/standard-adapter/validation.md#translating-custom-codes) and [HTTP Errors — Custom Codes](../errors/http-errors.md#custom-codes).

## Raises

API-level `raises` declares which errors all endpoints can raise:

```ruby
Apiwork::API.define '/api/v1' do
  raises :bad_request, :unauthorized, :forbidden, :not_found, :internal_server_error
end
```

These appear in generated [OpenAPI exports](../exports/openapi.md) as possible responses for all endpoints.

#### See also

- [API::Base reference](../../reference/api/base.md) — `info` and `raises` methods
