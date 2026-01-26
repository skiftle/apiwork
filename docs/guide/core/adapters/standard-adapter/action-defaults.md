---
order: 2
---

# Action Defaults

When using `representation`, the adapter generates typed requests and responses for each action.

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

### `index`

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
  "pagination": {
    "current": 1,
    "next": 2,
    "prev": null,
    "total": 5,
    "items": 100
  }
}
```

### `show`

Returns a single record by ID.

**Request:**

- `include` — eager load associations (if any exist)

**Response:**

```json
{
  "invoice": {
    "id": 1,
    "number": "INV-001"
  }
}
```

### `create`

Creates a new record. Returns 201 Created on success.

**Request:**

- Body with `writable: true` attributes wrapped in root key
- `include` — eager load associations in the response

**Response:**

```json
{
  "invoice": {
    "id": 1,
    "number": "INV-001"
  }
}
```

### `update`

Updates an existing record.

**Request:**

- Body with `writable: true` attributes (all optional)
- `include` — eager load associations in the response

**Response:**

```json
{
  "invoice": {
    "id": 1,
    "number": "INV-002"
  }
}
```

### `destroy`

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
  "invoice": { ... }
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
      array :invoices do
        object do
          string :number
        end
      end
    end
  end

  response do
    body do
      integer :created_count
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
      datetime :deleted_at
    end
  end
end
```

## Override Defaults

Contract definitions merge with representation-generated types by default. See [Declaration Merging](../contracts/actions.md#declaration-merging) for details.

Use `replace: true` to completely override:

```ruby
action :create do
  request replace: true do
    body do
      object :invoice do
        string :title
      end
    end
  end
end
```

### Override 204 No Content

Use `replace: true` to override the default 204 response.

To return data from destroy:

```ruby
action :destroy do
  response replace: true do
    body do
      datetime :deleted_at
    end
  end
end
```

To return meta from destroy:

```ruby
action :destroy do
  response replace: true do
    body do
      meta do
        datetime :deleted_at
      end
    end
  end
end
```

```ruby
def destroy
  invoice = Invoice.find(params[:id])
  invoice.destroy
  expose invoice, meta: { deleted_at: Time.current }
end
```

See [meta](../contracts/actions.md#meta) and [no_content!](../contracts/actions.md#no_content) for details.

