---
order: 2
---

# Action Defaults

When using `schema!`, the adapter automatically generates typed requests and responses for the resource's actions. This page documents the default behavior for each action.

## Overview

| Action            | Type       | Request                     | Response                             | HTTP Status    |
| ----------------- | ---------- | --------------------------- | ------------------------------------ | -------------- |
| `index`           | collection | filter, sort, page, include | `{ resources[], pagination, meta? }` | 200 OK         |
| `show`            | member     | include                     | `{ resource, meta? }`                | 200 OK         |
| `create`          | collection | body + include              | `{ resource, meta? }`                | 201 Created    |
| `update`          | member     | body + include              | `{ resource, meta? }`                | 200 OK         |
| `destroy`         | member     | (none)                      | (no body)                            | 204 No Content |
| Custom member     | member     | include                     | `{ resource, meta? }`                | 200 OK         |
| Custom collection | collection | (none)                      | (none)                               | -              |
| Custom DELETE     | any        | (none)                      | (no body)                            | 204 No Content |

## Standard Actions

### index

Returns a paginated collection with filtering and sorting.

**Request:**

- `filter` — filter records by attributes and associations
- `sort` — order results by attributes
- `page` — pagination parameters (number/size or cursor)
- `include` — eager load associations

**Response:**

```json
{
  "invoices": [...],
  "pagination": { "currentPage": 1, "totalPages": 5 },
  "meta": {}
}
```

### show

Returns a single record by ID.

**Request:**

- `include` — eager load associations (if any exist)

**Response:**

```json
{
  "invoice": { "id": 1, "number": "INV-001" },
  "meta": {}
}
```

### create

Creates a new record. Returns 201 Created on success.

**Request:**

- Body with `writable: true` attributes wrapped in root key
- `include` — eager load associations in the response

**Response:**

```json
{
  "invoice": { "id": 1, "number": "INV-001" },
  "meta": {}
}
```

### update

Updates an existing record.

**Request:**

- Body with `writable: true` attributes (all optional)
- `include` — eager load associations in the response

**Response:**

```json
{
  "invoice": { "id": 1, "number": "INV-002" },
  "meta": {}
}
```

### destroy

Deletes a record. Returns 204 No Content with no body.

**Request:** None

**Response:** None (HTTP 204)

This is the default for all DELETE method actions. See [no_content!](../contracts/actions.md#no_content) to override.

## Custom Actions

### Member Actions

Custom member actions (e.g., `patch :archive`) get:

- `include` query param (if associations exist)
- Single resource response

```ruby
# API definition
resources :invoices do
  member do
    patch :archive
  end
end
```

Default response:

```json
{
  "invoice": { ... },
  "meta": {}
}
```

### Collection Actions

Custom collection actions get **no default request or response**. You must define them explicitly:

```ruby
# API definition
resources :invoices do
  collection do
    post :bulk_create
  end
end

# Contract
action :bulk_create do
  request do
    body do
      param :invoices, type: :array do
        param :number, type: :string
      end
    end
  end

  response do
    body do
      param :created_count, type: :integer
    end
  end
end
```

### DELETE Actions

Any action with `delete` method returns 204 No Content by default:

```ruby
# API definition
resources :invoices do
  member do
    delete :soft_delete
  end
end
```

To return data instead, define a response body:

```ruby
action :soft_delete do
  response do
    body do
      param :deleted_at, type: :datetime
    end
  end
end
```

## Override Defaults

### Merging

By default, contract definitions merge with schema-generated types:

```ruby
class InvoiceContract < Apiwork::Contract::Base
  schema!

  action :create do
    request do
      body do
        # Adds to writable attributes
        param :invoice, type: :object do
          param :custom_field, type: :string
        end
      end
    end
  end
end
```

### Replacing

Use `replace: true` to completely override the default:

```ruby
action :create do
  request replace: true do
    body do
      # Only these fields, no schema attributes
      param :invoice, type: :object do
        param :title, type: :string
      end
    end
  end
end

action :show do
  response replace: true do
    body do
      # Custom response shape
      param :summary, type: :string
      param :total, type: :decimal
    end
  end
end
```

### Override 204 No Content

To return data from destroy:

```ruby
action :destroy do
  response do
    body do
      param :deleted_at, type: :datetime
    end
  end
end
```

To return 200 OK with meta support:

```ruby
action :destroy do
  response {}  # Empty body, but 200 OK with meta
end
```

See [no_content!](../contracts/actions.md#no_content) for details.
