# Apiwork Documentation

**Love Rails for building APIs? Love typed frontends? Tired of writing OpenAPI schemas by hand?**

Apiwork might be exactly what you need.

Apiwork is a Rails framework that gives you type-safe, self-documenting REST APIs with zero configuration. Write your schema once, get automatic TypeScript types, Zod validation, OpenAPI specs, and powerful querying—all from the same source of truth.

## Why Apiwork?

**You shouldn't have to choose between Rails productivity and frontend type safety.**

With Apiwork, you get:

- **Type-safe everything** - From database to frontend. Write your schema once, generate TypeScript types, Zod validators, and OpenAPI specs automatically. No more drift between backend and frontend.

- **Rails-native design** - Builds on Rails conventions you already know. `accepts_nested_attributes_for`, strong parameters, and familiar routing—but better. No fighting the framework.

- **Powerful querying, zero code** - Filter, sort, paginate through URL params. Association filtering. Operator-based conditions. All auto-generated from your schema attributes.

- **Convention over configuration** - Define your schema, link it to a contract, mount your routes. Done. Apiwork handles the rest—route resolution, serialization, validation, query building.

### The philosophy: Inherit everything, override when needed

**Guess what? Most of your API schema is already defined—in your database.**

Why write types twice? Apiwork reads your database schema—column types, nullability, defaults—and infers everything automatically. Your `string` column becomes `:string` in contracts and `z.string()` in Zod. Your `null: false` constraint makes fields `required: true`. Your enums become TypeScript unions.

The Rails conventions you rely on—`accepts_nested_attributes_for`, model validations, associations—are the foundation. Apiwork doesn't replace them, it amplifies them. We inherit as much as possible from Rails and your database, then let you override only what you need.

**This is the philosophy: maximize convenience through inheritance, stay flexible.**

If you've ever:
- Manually maintained an OpenAPI spec that's out of sync with your code
- Written the same type definitions in Ruby and TypeScript
- Built custom filtering/sorting logic for every endpoint
- Wished Rails had better API tooling

...then Apiwork is for you.

## Quick example

```ruby
# Define your API routes
Apiwork::API.draw '/api/v1' do
  resources :posts do
    resources :comments
  end
end

# Define your schema
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
  attribute :published, filterable: true, writable: true

  has_many :comments, schema: CommentSchema
end

# Define your contract
class PostContract < Apiwork::Contract::Base
  schema PostSchema

  action :create do
    input do
      param :title, type: :string, required: true
      param :body, type: :string, required: true
    end
  end
end

# Use in your controller
class PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    posts = query(Post.all)  # Auto-applies filter, sort, pagination
    respond_with posts        # Auto-serializes with schema
  end

  def create
    post = Post.create(action_params)  # Validated params
    respond_with post, status: :created
  end
end
```

Now you have a fully functional API with:
- Automatic filtering: `GET /posts?filter[published]=true`
- Automatic sorting: `GET /posts?sort[created_at]=desc`
- Automatic pagination: `GET /posts?page[number]=2&page[size]=25`
- Type-safe inputs and outputs
- OpenAPI documentation: `GET /api/v1/.schema/openapi`

## Documentation structure

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
- [Parameters](./contracts/parameters.md) - Parameter types and options
- [Custom Types](./contracts/custom-types.md) - Reusable type definitions
- [Lexical Scoping](./contracts/lexical-scoping.md) - Type scoping rules
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
Enable powerful queries through URL parameters:
- [Introduction](./querying/introduction.md) - Query DSL overview
- [Filtering](./querying/filtering.md) - Filter data with operators
- [Sorting](./querying/sorting.md) - Sort results
- [Pagination](./querying/pagination.md) - Page-based pagination
- [Includes](./querying/includes.md) - Eager load associations

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
