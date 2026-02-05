---
order: 2
---

# Configuration

API-level configuration applies to all resources within the API.

## Key Format

Control how keys are transformed in requests and responses:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel
end
```

Options:

| Option            | Ruby Key     | JSON Key     |
| ----------------- | ------------ | ------------ |
| `:keep` (default) | `created_at` | `created_at` |
| `:camel`          | `created_at` | `createdAt`  |
| `:kebab`          | `created_at` | `created-at` |
| `:underscore`     | `created_at` | `created_at` |

## Path Format

Control how URL path segments are formatted:

```ruby
Apiwork::API.define '/api/v1' do
  path_format :kebab

  resources :recurring_invoices
  # Routes: GET /api/v1/recurring-invoices
end
```

Options:

| Option            | Example Input         | URL Path             |
| ----------------- | --------------------- | -------------------- |
| `:keep` (default) | `:recurring_invoices` | `recurring_invoices` |
| `:kebab`          | `:recurring_invoices` | `recurring-invoices` |
| `:camel`          | `:recurring_invoices` | `recurringInvoices`  |
| `:underscore`     | `:recurring_invoices` | `recurring_invoices` |

### Custom Member and Collection Actions

Custom actions are also transformed:

```ruby
Apiwork::API.define '/api/v1' do
  path_format :kebab

  resources :invoices do
    member do
      patch :mark_as_paid      # PATCH /invoices/:id/mark-as-paid
    end
    collection do
      get :past_due            # GET /invoices/past-due
    end
  end
end
```

::: info Path Segments Only
`path_format` transforms resource and action names. It does not affect:

- The mount path (`/api/v1` stays as written)
- Route parameters (`:id`, `:post_id`)
- Query parameters
- Request/response payload keys (use [key_format](#key-format) for those)
  :::

### Explicit Path Override

Bypass formatting with explicit `path:`:

```ruby
resources :recurring_invoices, path: 'invoices'
# Routes: GET /api/v1/invoices (ignores path_format)
```

### With Key Format

`path_format` and `key_format` are independent:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel        # Payload keys: createdAt
  path_format :kebab       # URL paths: recurring-invoices
end
```

## Adapter

The adapter handles filtering, sorting, pagination, and serialization.

### Configuring the Built-in Adapter

Without arguments, configure the default adapter:

```ruby
Apiwork::API.define '/api/v1' do
  adapter do
    pagination do
      default_size 20
      max_size 100
    end
  end
end
```

[Standard Adapter](../adapters/standard-adapter/introduction.md) covers pagination strategies, filtering operators, and sorting options.

### Using a Custom Adapter

Switch to a registered adapter:

```ruby
Apiwork::API.define '/api/v1' do
  adapter :jsonapi
end
```

Or switch and configure:

```ruby
Apiwork::API.define '/api/v1' do
  adapter :jsonapi do
    pagination do
      strategy :cursor
    end
  end
end
```

See [Custom Adapters](../adapters/custom-adapters/introduction.md) for creating your own.

#### See also

- [API::Base reference](../../../reference/api-base.md) — all configuration methods and options
