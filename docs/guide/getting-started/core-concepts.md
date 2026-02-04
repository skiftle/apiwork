---
order: 3
---

# Core Concepts

Apiwork is built around four core layers: **API definitions**, **contracts**, **representations**, and **adapters**.

API definitions describe your API surface and endpoints. Contracts define the data model and constraints at the boundary. Representations act as a bridge between your domain models and the contract, while adapters interpret representations and provide the runtime.

Together they form a single source of truth that drives both [introspection](../core/introspection/introduction.md) and [execution](../core/adapters/introduction.md).

You can use Apiwork with just API definitions and contracts, or add representations and adapters to run a fully executable API. Apiwork ships with a built-in adapter that provides a complete API runtime out of the box.

## API Definition

The API definition lives in `config/apis/` and declares what resources your API exposes.

```ruby
Apiwork::API.define '/api/v1' do
  resources :posts do
    resources :comments
  end
end
```

This creates RESTful routes for posts and nested comments. Apiwork uses the Rails router — `resources` maps directly to Rails' `resources`.

You can also declare which [exports](../core/exports/introduction.md) to generate:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod

  resources :posts
end
```

These become available at `/.openapi`, `/.typescript`, and `/.zod`.

::: info
The path in `define '/api/v1'` combines with where you mount Apiwork in `routes.rb`. If you mount at `/` and define at `/api/v1`, your routes become `/api/v1/posts`.
:::

See [API Definitions](../core/api-definitions/introduction.md) for the full guide.

## Contract

Contracts validate requests and define response shapes. They live in `app/contracts/`.

```ruby
class PostContract < ApplicationContract
  action :create do
    request do
      body do
        string :title
        string :body
      end
    end

    response do
      body do
        integer :id
        string :title
        string :body
        datetime :created_at
      end
    end
  end
end
```

This defines what goes in and what comes out. The contract validates incoming requests and documents response shapes for generated exports.

## Controller

Controllers include `Apiwork::Controller` and have two differences from standard Rails:

- Use `expose` to return data
- Use `contract.query` and `contract.body` for validated params

```ruby
def create
  post = Post.create(contract.body[:post])
  expose post
end
```

- `contract.query` — URL parameters (filters, sorting, pagination)
- `contract.body` — request body (create/update payloads)

::: tip
Requests with undefined fields are rejected. `contract.query` and `contract.body` contain only validated fields.
:::

## Representation

Writing contracts by hand means defining every request type, response type, filter, and sort — for every action. That adds up.

A representation sits between your model and contract. It describes what to expose and how: filtering, sorting, writing. Apiwork uses this to build the contract and handle requests.

```ruby
class PostRepresentation < ApplicationRepresentation
  attribute :id
  attribute :title, writable: true, filterable: true
  attribute :body, writable: true
  attribute :published, filterable: true
  attribute :created_at, sortable: true
end
```

Each option does one thing:

| Option             | What it does                                         |
| ------------------ | ---------------------------------------------------- |
| `writable: true`   | Field can be set in create/update requests           |
| `filterable: true` | Field can be filtered via `?filter[field][op]=value` |
| `sortable: true`   | Field can be sorted via `?sort[field]=asc`           |

::: tip
You don't need to specify types. Apiwork reads your database columns and infers types, nullability, and defaults automatically.
:::

### Associations

Representations can include associations:

```ruby
has_many :comments, writable: true
belongs_to :author
has_one :profile, include: :always
```

- `writable: true` — allows nested attributes in create/update
- `include: :always` — always includes the association in responses

### From Representation to Contract

Use `representation` to connect a contract to its representation:

```ruby
class PostContract < ApplicationContract
  representation PostRepresentation
end
```

This single line generates typed definitions for all CRUD actions based on the representation's attributes and options.

::: tip
You can also write contracts entirely by hand without representations. This is useful for non-CRUD endpoints or custom APIs. See [Contracts](../core/contracts/introduction.md).
:::

The representation declares:

- Which fields exist (from `attribute`)
- Which can be written (from `writable: true`)
- Which can be filtered or sorted (from `filterable:` / `sortable:`)
- How associations nest (from `has_many`, `belongs_to`, etc.)

From this, the adapter generates types and runtime behavior. The [standard adapter](../core/adapters/standard-adapter/introduction.md) creates:

- Request types for create/update (writable fields only)
- Response types for all actions (all exposed fields)
- Filter types (filterable fields only)
- Sort types (sortable fields only)

See [Action Defaults](../core/adapters/standard-adapter/action-defaults.md) for what the standard adapter generates, and [Representations](../core/representations/introduction.md) for the full guide.

### Customizing Generated Actions

The defaults usually work. But you can extend or replace any action:

```ruby
class PostContract < ApplicationContract
  representation PostRepresentation

  action :index do
    request do
      query do
        string? :status
      end
    end
  end

  action :destroy do
    response replace: true do
      body do
        datetime :deleted_at
      end
    end
  end
end
```

See [Actions](../core/contracts/actions.md) for all action options.

## How They Connect

Here's how everything fits together:

```text
┌─────────────────────────────────────────────────────────────┐
│  config/apis/api_v1.rb                                      │
│  API Definition — declares resources and exports            │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/contracts/api/v1/post_contract.rb                      │
│  Contract — validates requests, uses representation for types      │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/representations/api/v1/post_representation.rb                          │
│  Representation — defines attributes, associations, permissions │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/models/post.rb                                         │
│  Model — database columns, validations, associations        │
└─────────────────────────────────────────────────────────────┘
```

**Request flow:**

1. Request arrives at `/api/v1/posts`
2. API definition routes to `PostsController`
3. Contract validates the request using representation types
4. Controller processes the request
5. Representation serializes the response

Representation is the single source of truth. Contracts and serialization both derive from it.

## Next Steps

Next:

- [Quick Start](./quick-start.md) — build a complete API with validation, filtering, and exports
