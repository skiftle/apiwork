---
order: 1
---

# Introduction

Apiwork uses a unified error system. Every error — whether from contract validation, model validation, or business logic — follows the same structure. Clients receive consistent, predictable responses regardless of where the failure occurred.

## The Issue

At the center of Apiwork's error handling is the **Issue**. An issue represents a single problem with a request or response:

```ruby
Apiwork::Issue.new(
  code: :field_missing,
  detail: "Field required",
  path: [:invoice, :number],
  meta: { field: :number }
)
```

Every issue contains:

| Field | Description |
|-------|-------------|
| `code` | A machine-readable symbol (`:field_missing`, `:invalid_type`, etc.) |
| `detail` | A human-readable message |
| `path` | An array representing the location in the request body |
| `pointer` | A JSON Pointer string derived from the path |
| `meta` | Additional context (constraints, expected values, etc.) |

## JSON Response

When errors occur, Apiwork renders them as JSON:

```json
{
  "issues": [
    {
      "code": "field_missing",
      "detail": "Field required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": { "field": "number" }
    }
  ]
}
```

The `issues` array contains all problems found. Clients can iterate through them, display messages to users, or highlight specific fields using the path or pointer.

## Error Types

Apiwork distinguishes between different error categories:

| Error | HTTP Status | When |
|-------|-------------|------|
| `ContractError` | 400 Bad Request | Request doesn't match the contract |
| `ValidationError` | 422 Unprocessable Entity | Model validation failed |

Both inherit from `ConstraintError` and carry an array of issues. The controller automatically catches these and renders the appropriate response.

## Error Flow

```
Request arrives
    ↓
Contract validates request shape
    ↓ (fails → ContractError → 400)
Controller runs
    ↓
Model saves
    ↓ (fails → ValidationError → 422)
Response rendered
```

Contract errors happen before your controller code runs — the request never reaches your models. Validation errors happen after, when ActiveRecord validations fail during save.

## Handling Errors

The `Apiwork::Controller::Concern` automatically rescues constraint errors:

```ruby
class PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def create
    post = Post.create(contract.body[:post])
    respond_with post  # Automatically handles validation errors
  end
end
```

If `Post.create` fails validation, `respond_with` detects the errors and raises a `ValidationError`. The concern catches it and renders the issues with a 422 status.

For custom error handling, use `render_error`:

```ruby
def create
  post = Post.new(contract.body[:post])

  unless current_user.can_create_posts?
    issue = Apiwork::Issue.new(
      code: :unauthorized,
      detail: "You don't have permission to create posts",
      path: [],
      meta: {}
    )
    return render_error [issue], status: :forbidden
  end

  post.save!
  respond_with post
end
```

## Why This Matters

A consistent error format means:

- **Client simplicity** — One error parser handles everything
- **Precise feedback** — Paths point to exact fields
- **Rich context** — Metadata helps build better error messages
- **Predictability** — Same shape whether contract or model fails

The next sections cover each error type in detail.
