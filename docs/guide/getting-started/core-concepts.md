---
order: 3
---

# Core Concepts

Apiwork is built around three main pieces: **API definitions**, **schemas**, and **contracts**. Each has a specific job, and together they describe everything about your API.

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

## Schema

Schemas define how your data is serialized and what can be queried. They live in `app/schemas/`:

```ruby
class PostSchema < ApplicationSchema
  attribute :id
  attribute :title, writable: true, filterable: true
  attribute :body, writable: true
  attribute :published, filterable: true
  attribute :created_at, sortable: true
end
```

Each option controls one thing:

| Option | What it does |
|--------|--------------|
| `writable: true` | Field can be set in create/update requests |
| `filterable: true` | Field can be filtered via `?filter[field][op]=value` |
| `sortable: true` | Field can be sorted via `?sort[field]=asc` |

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

## Contract

Contracts validate requests and define response shapes. The simplest contract uses `schema!` to pull everything from the schema:

```ruby
class PostContract < ApplicationContract
  schema!
end
```

That's it. `schema!` imports:

- **Writable fields** for create/update request bodies
- **Filterable fields** for query parameters
- **Sortable fields** for sort parameters
- **All fields** for response bodies

### Custom Actions

Need an action beyond standard CRUD? Define it explicitly:

```ruby
class PostContract < ApplicationContract
  schema!

  action :publish do
    response do
      body do
        param :post, type: :post
      end
    end
  end
end
```

::: info
You can also write contracts entirely by hand without `schema!`. This gives you full control when you need it — see [Contracts](../core/contracts/introduction.md) for details.
:::

## Controller

Controllers look like regular Rails controllers with two key differences:

1. Use `respond` instead of `render`
2. Access validated params via `contract.query` and `contract.body`

```ruby
def create
  post = Post.create!(contract.body[:post])
  respond post, status: :created
end
```

- `contract.query` — URL parameters (filters, sorting, pagination)
- `contract.body` — request body (create/update payloads)

::: tip
`contract.query` and `contract.body` replace Strong Parameters. They contain only the fields defined in your schema — unknown fields are filtered out before your controller runs.
:::

## How They Connect

Here's how everything fits together:

```
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
