# Apiwork

Apiwork is a small framework for building **contract-driven, type-safe APIs in Rails**. You still write your controllers and actions the way you’re used to — but Apiwork takes care of everything around them: validation, serialization, queries, and documentation.

You define your **contracts**, often based on simple **schemas** that describe your models, their attributes, and relationships. Apiwork can then validate input and output, build queries, and keep your API both safe and capable. And as a natural side effect, it can generate **OpenAPI**, **Zod**, and **TypeScript** definitions — all from one place.

---

## Design

Apiwork builds on Rails without changing how you write it. Controllers stay clean and explicit. Requests and responses go through a **contract layer** that defines, coerces, and validates data. Input is validated before it reaches your action. Output is validated too — but only in development, to catch silent drift early. In production, those contracts define structure, not overhead.

There’s no hidden magic here — Apiwork doesn’t patch or override Rails. It’s designed to be explicit and transparent, so you always know what happens and where. The result is an API that feels familiar, stays predictable, and documents itself as you go.

---

## In practice

Normally you’d use a few different gems for this — one for serializers, one for pagination, one for validation, one for OpenAPI. Apiwork brings those ideas together into a single, coherent layer on top of Rails — because in reality, these parts are already tightly coupled anyway, and it just works better when they live in one place.

Most of the time, you don’t even write the contracts yourself. You just pick which attributes to expose, and Apiwork figures out the rest from your models and database. Column types, nullability, defaults, enums — it’s all there already.

---

## What you get

- Contract-driven input and output validation
- Automatic OpenAPI, Zod, and TypeScript generation
- Built-in filtering, sorting, and pagination
- **`include` support** — choose which related records to include, safely validated and type-checked
- **Nested relation saving** — handle `has_many` and `belongs_to` updates automatically
- Automatic N+1 detection and preloading
- Controller-first design — no abstraction over your logic
- Predictable serialization and error handling
- Rails conventions, made explicit and type-safe

---

## What you give up

In practice, almost nothing. But there are a few small constraints to make everything work as intended:

- Controllers should respond using **Apiwork’s `respond_with`**, which behaves like the classic Rails helper but adds automatic output validation and serialization.
- Requests should use **Apiwork’s validated request objects** instead of raw Rails `params`, since that’s where input coercion and validation happen.
- Routes aren’t defined directly in `routes.rb`. Instead, they live inside your **API definitions**, using almost the same DSL as Rails’ `resources do ... end`.  
  This allows Apiwork to introspect routes, contracts, and schemas together — keeping everything in sync.

That’s about it. You keep the Rails you know — just with stronger boundaries, smarter defaults, and a safer surface.

---

## Quick example

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  schema :openapi

  resources :posts
end

# config/routes.rb
 mount Apiwork.routes => '/'

# app/schemas/post_schema.rb
class PostSchema < Apiwork::Schema::Base
  model Post

  with_options filterable: true, sortable: true do
    attribute :id,
    attribute :title

    with_options writable: true do
        attribute :body
        attribute :published
        has_many :comments, include: true
    end
  end
end

# app/contracts/post_contract.rb
class PostContract < Apiwork::Contract::Base
  schema PostSchema
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    respond_with Post.all
  end

  def create
    post = Post.create(action_params)
    respond_with post
  end
end
```

Now you have a fully functional API with:

- Automatic filtering: `GET /posts?filter[published]=true`
- Automatic sorting: `GET /posts?sort[created_at]=desc`
- Automatic pagination: `GET /posts?page[number]=2&page[size]=25`
- Automatic inclusion of relationships
- Nestade saves
- Type-safe inputs and outputs
- OpenAPI documentation: `GET /api/v1/.schema/openapi`

### Getting Started

Start here if you're new to Apiwork:

- [Introduction](./getting-started/introduction.md) - What is Apiwork and why use it?
- [Installation](./getting-started/installation.md) - Get up and running
- [Quick Start](./getting-started/quick-start.md) - Build your first API in 5 minutes
- [Core Concepts](./getting-started/core-concepts.md) - Understand the architecture

### API Definition

Define your routes and API structure:

- [Introduction](./api-definition/introduction.md) - API.draw overview
- [Resources](./api-definition/resources.md) - Resources and nested resources
- [Actions](./api-definition/actions.md) - Member and collection actions
- [Configuration](./api-definition/configuration.md) - Schema endpoints and documentation
- [Routing Options](./api-definition/routing-options.md) - Customize routes
- [Advanced](./api-definition/advanced.md) - with_options and concerns

### Schemas

Define your data models and serialization:

- [Introduction](./schemas/introduction.md) - What are schemas?
- [Attributes](./schemas/attributes.md) - Define attributes and types
- [Associations](./schemas/associations.md) - Relations between models
- [Configuration](./schemas/configuration.md) - Schema-level settings
- [Writable Attributes](./schemas/writable-attributes.md) - Accept user input
- [Filtering & Sorting](./schemas/filtering-sorting.md) - Make fields queryable
- [Advanced](./schemas/advanced.md) - Conditional logic and patterns

### Contracts

Validate inputs and outputs:

- [Introduction](./contracts/introduction.md) - What are contracts?
- [Actions](./contracts/actions.md) - Define action contracts
- [Params](./contracts/params.md) - Parameter types and options
- [Literal Types](./contracts/literal-types.md) - Exact value matching
- [Discriminated Unions](./contracts/discriminated-unions.md) - Type-safe unions
- [Enums](./contracts/enums.md) - Restrict values to specific options
- [Custom Types](./contracts/custom-types.md) - Reusable type definitions
- [Objects & Arrays](./contracts/objects-arrays.md) - Nested structures
- [Union Types](./contracts/union-types.md) - Multiple possible types
- [Validation](./contracts/validation.md) - How validation works

### Controllers

Integrate Apiwork into your controllers:

- [Introduction](./controllers/introduction.md) - Controller integration
- [Helpers](./controllers/helpers.md) - query(), respond_with(), action_params
- [Validation](./controllers/validation.md) - Input validation
- [Response Handling](./controllers/response-handling.md) - Format responses

### Querying

Enable powerful queries through URL parameters. Mark attributes as `filterable`, `sortable`, or `serializable` in your schema, and Apiwork auto-generates query params and handles the SQL:

- [Introduction](./querying/introduction.md) - How the query system works
- [Filtering](./querying/filtering.md) - Filter with type-specific operators
- [Sorting](./querying/sorting.md) - Sort by single or multiple fields
- [Pagination](./querying/pagination.md) - Page-based pagination with metadata
- [Includes](./querying/includes.md) - Eager load associations, prevent N+1
- [Combining Queries](./querying/combining.md) - Real-world examples

### Schema Generation

Generate schemas for your frontend:

- [Introduction](./schema-generation/introduction.md) - Overview
- [OpenAPI](./schema-generation/openapi.md) - OpenAPI 3.1 generation
- [TypeScript](./schema-generation/typescript.md) - TypeScript types
- [Zod](./schema-generation/zod.md) - Zod validation schemas

### Integration

Understand how everything works together:

- [Full Stack Flow](./integration/full-stack-flow.md) - Request to response
- [Conventions](./integration/conventions.md) - File structure and naming
- [Best Practices](./integration/best-practices.md) - Patterns and tips

### Reference

Complete technical reference:

- [Configuration](./reference/configuration.md) - Global config options
- [Error Handling](./reference/error-handling.md) - Errors and modes
- [Response Format](./reference/response-format.md) - Response envelope

## Community and Support

- GitHub: [anthropics/apiwork](https://github.com/anthropics/apiwork)
- Issues: [Report bugs or request features](https://github.com/anthropics/apiwork/issues)

## License

Apiwork is released under the MIT License.
