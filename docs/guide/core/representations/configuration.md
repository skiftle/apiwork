---
order: 7
---

# Configuration

Representation-level settings for root keys, metadata, abstract declarations, and adapter options.

## Metadata

Add documentation to your representation for export generation:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  description "A customer invoice with line items and payment tracking"
  example { id: 1, number: "INV-2024-001", status: "sent" }
end
```

| Method | Purpose |
|--------|---------|
| `description` | Human-readable text shown in OpenAPI, TypeScript, and Zod exports |
| `example` | Example value shown in generated exports |

These appear on the generated response type for this representation.

### Deprecation

Mark a representation as deprecated:

```ruby
class LegacyInvoiceRepresentation < Apiwork::Representation::Base
  deprecated!
end
```

The representation and its generated types are marked as deprecated in all exports. Deprecated representations continue to function at runtime.

## Abstract Representations

Mark a representation as abstract when it should not be used directly:

```ruby
class ApplicationRepresentation < Apiwork::Representation::Base
  abstract!
end

class InvoiceRepresentation < ApplicationRepresentation
  attribute :id
  attribute :number
end
```

Abstract representations are not registered with the adapter and do not generate types. They exist as base classes for shared configuration.

Apiwork also marks representations as abstract automatically when they serve as the base class in a [Single Table Inheritance](./single-table-inheritance.md) hierarchy.

## Root Key

By default, representations derive the JSON root key from the model name:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  model Post
end

# Response: { "post": {...} } or { "posts": [...] }
```

Override with custom keys:

```ruby
class PostRepresentation < Apiwork::Representation::Base
  root :article
  # Response: { "article": {...} } or { "articles": [...] }
end
```

Specify both singular and plural:

```ruby
class PersonRepresentation < Apiwork::Representation::Base
  root :person, :people
end
```

## Adapter Configuration

Adapters may provide configuration options that can be set at the API or representation level. Representations can override API-level adapter settings.

```ruby
class ActivityRepresentation < Apiwork::Representation::Base
  adapter do
    # Adapter-specific options
  end
end
```

Settings resolve in this order (first defined wins):

1. **Representation** `adapter` block — most specific
2. **API definition** `adapter` block — API-wide defaults
3. **Adapter defaults** — built-in fallbacks

If using the Standard Adapter, configure pagination strategies with the `adapter` block. See [Standard Adapter: Pagination](../adapters/standard-adapter/pagination.md) for available options.

#### See also

- [Representation::Base reference](../../../reference/apiwork/representation/base.md) — all representation methods and options
