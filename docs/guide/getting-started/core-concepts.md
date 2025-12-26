---
order: 3
---

# Core Concepts

Apiwork is built around three main pieces: **API definitions**, **contracts**, and **schemas**. Each has a specific job, and together they describe everything about your API.

## API Definition

The API definition lives in `config/apis/` and declares what resources your API exposes:

```ruby
Apiwork::API.define '/api/v1' do
  resources :posts do
    resources :comments
  end
end
```

This creates RESTful routes for posts and nested comments. Under the hood, Apiwork uses the Rails router — `resources` works exactly as you'd expect.

You can also declare which specs to generate:

```ruby
Apiwork::API.define '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod

  resources :posts
end
```

These become available at `/.spec/openapi`, `/.spec/typescript`, and `/.spec/zod`.

::: info
The path in `define '/api/v1'` combines with where you mount Apiwork in `routes.rb`. If you mount at `/` and define at `/api/v1`, your routes become `/api/v1/posts`.
:::

## Contract

Contracts validate requests and define response shapes. They live in `app/contracts/`:

```ruby
class PostContract < ApplicationContract
  action :create do
    request do
      body do
        param :title, type: :string
        param :body, type: :string
      end
    end

    response do
      body do
        param :id, type: :integer
        param :title, type: :string
        param :body, type: :string
        param :created_at, type: :datetime
      end
    end
  end
end
```

This defines what goes in and what comes out. The contract validates incoming requests and documents response shapes for generated specs.

## Schema

Writing contracts by hand means defining every request type, response type, filter, and sort — for every action. That adds up.

A schema bridges the gap. It sits between your ActiveRecord model and the contract, describing what to expose and how it behaves — what can be filtered, sorted, and written. Apiwork uses this to build the contract and handle requests.

```ruby
class PostSchema < ApplicationSchema
  attribute :id
  attribute :title, writable: true, filterable: true
  attribute :body, writable: true
  attribute :published, filterable: true
  attribute :created_at, sortable: true
end
```

Each flag controls one thing:

| Flag               | What it does                                         |
| ------------------ | ---------------------------------------------------- |
| `writable: true`   | Field can be set in create/update requests           |
| `filterable: true` | Field can be filtered via `?filter[field][op]=value` |
| `sortable: true`   | Field can be sorted via `?sort[field]=asc`           |

::: tip
You don't need to specify types. Apiwork reads your database columns and infers types, nullability, and defaults automatically.
:::

### Associations

Schemas can include associations:

```ruby
has_many :comments, writable: true
belongs_to :author
has_one :profile, include: :always
```

- `writable: true` — allows nested attributes in create/update
- `include: :always` — always includes the association in responses

### From Schema to Contract

Use `schema!` to generate a complete contract from your schema:

```ruby
class PostContract < ApplicationContract
  schema!
end
```

This single line generates typed definitions for all CRUD actions.

::: tip
You can also write contracts entirely by hand without schemas. This is useful for non-CRUD endpoints or custom APIs. See [Contracts](../core/contracts/introduction.md).
:::

The schema knows:
- Which fields exist (from `attribute`)
- Which can be written (from `writable: true`)
- Which can be filtered or sorted (from `filterable:` / `sortable:`)
- How associations nest (from `has_many`, `belongs_to`, etc.)

From this, Apiwork generates:
- Request types for create/update (writable fields only)
- Response types for all actions (all exposed fields)
- Filter types (filterable fields only)
- Sort types (sortable fields only)

See [Action Defaults](../core/execution-engine/action-defaults.md) for what gets generated.

### Customizing Generated Actions

The defaults usually work. But you can extend or replace any action:

```ruby
class PostContract < ApplicationContract
  schema!

  action :index do
    request do
      query do
        param :status, type: :string, optional: true
      end
    end
  end

  action :destroy do
    response replace: true do
      body do
        param :deleted_at, type: :datetime
      end
    end
  end
end
```

## Controller

Controllers look like regular Rails controllers with two key differences:

1. Use `expose` to return data
2. Access validated params via `contract.query` and `contract.body`

```ruby
def create
  post = Post.create(contract.body[:post])
  expose post
end
```

- `contract.query` — URL parameters (filters, sorting, pagination)
- `contract.body` — request body (create/update payloads)

::: tip
`contract.query` and `contract.body` replace Strong Parameters. They contain only the fields defined in your schema — unknown fields are filtered out before your controller runs.
:::

## How They Connect

Here's how everything fits together:

```text
┌─────────────────────────────────────────────────────────────┐
│  config/apis/api_v1.rb                                      │
│  API Definition — declares resources and specs              │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/contracts/api/v1/post_contract.rb                      │
│  Contract — validates requests, uses schema! for types      │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/schemas/api/v1/post_schema.rb                          │
│  Schema — defines attributes, associations, permissions     │
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
3. Contract validates the request using schema types
4. Controller processes the request
5. Schema serializes the response

**The key insight:** Schema is the single source of truth. It knows your data shape, and both contracts (for validation) and serialization (for responses) derive from it.

## Next Steps

Now that you understand the concepts, let's build something:

- [Quick Start](./quick-start.md) — build a complete API with validation, filtering, and specs
