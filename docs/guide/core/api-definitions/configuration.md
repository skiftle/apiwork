---
order: 3
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
| `:pascal`         | `created_at` | `CreatedAt`  |
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

| Option            | Example Input         | URL Path              |
| ----------------- | --------------------- | --------------------- |
| `:keep` (default) | `:recurring_invoices` | `recurring_invoices`  |
| `:camel`          | `:recurring_invoices` | `recurringInvoices`   |
| `:pascal`         | `:recurring_invoices` | `RecurringInvoices`   |
| `:kebab`          | `:recurring_invoices` | `recurring-invoices`  |
| `:underscore`     | `:recurring_invoices` | `recurring_invoices`  |

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

::: info What path_format transforms
`path_format` transforms all URL path segments:

- The base path (`/cool_man` becomes `/cool-man` with `:kebab`)
- Resource names (`recurring_invoices` becomes `recurring-invoices`)
- Custom action names (`mark_as_paid` becomes `mark-as-paid`)
- Explicit `path:` options

It does not affect:

- Route parameters (`:id`, `:post_id`)
- Query parameters
- Request/response payload keys (use [key_format](#key-format) for those)
:::

### Explicit Path Override

Override the resource name with explicit `path:`:

```ruby
resources :recurring, path: 'recurring_invoices'
# With path_format :kebab: GET /api/v1/recurring-invoices
# Controller: RecurringController (unchanged)
```

The explicit path is still transformed according to `path_format`.

### With Key Format

`path_format` and `key_format` are independent:

```ruby
Apiwork::API.define '/api/v1' do
  key_format :camel        # Payload keys: createdAt
  path_format :kebab       # URL paths: recurring-invoices
end
```

## Adapter Configuration

The `adapter` block configures the Standard Adapter (default). If using a custom adapter, configuration may differ.

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

See [Standard Adapter](../adapters/standard-adapter/) for all configuration options.

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

See [Custom Adapters](../adapters/custom-adapters/) for creating your own.

#### See also

- [API::Base reference](../../../reference/apiwork/api/base.md) — all configuration methods and options
