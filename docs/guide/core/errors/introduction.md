---
order: 1
---

# Introduction

Apiwork uses a unified error system. Every error — whether from contract validation, model validation, or HTTP responses — follows the same structure. Clients receive consistent, predictable responses regardless of where the failure occurred.

## The Issue Object

At the center of Apiwork's error handling is the **Issue** class. Each issue represents a single problem with a request:

```ruby
Apiwork::Issue.new(
  layer: :contract,
  code: :field_missing,
  detail: "Required",
  path: [:invoice, :number],
  meta: { field: :number, type: :string }
)
```

Every error contains:

| Field     | Description                                                         |
| --------- | ------------------------------------------------------------------- |
| `layer`   | Origin of the error: `"contract"`, `"domain"`, or `"http"`          |
| `code`    | A machine-readable symbol (`:field_missing`, `:invalid_type`, etc.) |
| `detail`  | A human-readable message                                            |
| `path`    | An array representing the location in the request body              |
| `pointer` | A JSON Pointer string derived from the path                         |
| `meta`    | Additional context (constraints, expected values, etc.)             |

## JSON Response

When errors occur, Apiwork renders them as JSON:

```json
{
  "errors": [
    {
      "layer": "contract",
      "code": "field_missing",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": { "field": "number", "type": "string" }
    }
  ]
}
```

The `errors` array contains all problems found. Clients can iterate through them, display messages to users, or highlight specific fields using the path or pointer.

## Error Layers

The `layer` field indicates where the error originated:

| Layer      | HTTP Status | Description                             |
| ---------- | ----------- | --------------------------------------- |
| `contract` | 400         | Request shape validation                |
| `domain`   | 422         | Business rule validation (ActiveRecord) |
| `http`     | Varies      | HTTP-level errors (not found, etc.)     |

This lets clients handle errors differently based on their source — for example, showing contract errors inline on form fields while displaying HTTP errors as alerts.

## Error Flow

```
Request arrives
     ↓
Contract validates request shape
     ↓ (if fails: 400 with contract errors)
Controller runs
     ↓
Model saves
     ↓ (if fails: 422 with domain errors)
Response rendered
```

Contract errors happen before your controller code runs — the request never reaches your models. Domain errors happen after, when ActiveRecord validations fail during save.

## Error Documentation

Each layer has its own documentation:

- [HTTP Errors](./http-errors.md) — `respond_with_error` and 20 built-in codes
- [Contract Errors](./contract-errors.md) — 28 codes for body, filter, sort, pagination
- [Domain Errors](./domain-errors.md) — 24 codes mapped from Rails validations
- [Custom Errors](./custom-errors.md) — Register your own error codes

## Handling Errors

The `Apiwork::Controller` module automatically rescues constraint errors:

```ruby
class PostsController < ApplicationController
  include Apiwork::Controller

  def create
    post = Post.create(contract.body[:post])
    respond post  # Automatically handles validation errors
  end
end
```

If `Post.create` fails validation, `respond` detects the errors and raises a `ValidationError`. The concern catches it and renders the errors with a 422 status.

For HTTP errors, use `respond_with_error`:

```ruby
class PostsController < ApplicationController
  include Apiwork::Controller

  rescue_from ActiveRecord::RecordNotFound do
    respond_with_error :not_found
  end

  def publish
    post = Post.find(params[:id])

    unless current_user.can_publish?(post)
      return respond_with_error :forbidden
    end

    post.publish!
    respond post
  end
end
```

## Why This Matters

A consistent error format means:

- **Client simplicity** — One error parser handles everything
- **Precise feedback** — Paths point to exact fields
- **Rich context** — Metadata helps build better error messages
- **Predictability** — Same shape whether contract, domain, or HTTP fails
