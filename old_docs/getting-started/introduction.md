# Introduction to Apiwork

Building APIs shouldn't be boring. But it often is.

You spend hours writing the same CRUD endpoints, validation logic, filter queries, pagination... over and over. Then you write OpenAPI specs. Then TypeScript types for your frontend. Then you realize they're all out of sync.

There has to be a better way.

## What if you could define your API once?

That's Apiwork. You describe what your API _is_ - what data it has, what operations it supports - and everything else just works.

No boilerplate. No repetition. No drift between backend and frontend.

## Here's what it looks like

```ruby
# Define your routes
Apiwork::API.draw '/api/v1' do
  resources :posts
end

# Describe your data
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
end

# Link it together
class PostContract < Apiwork::Contract::Base
  schema PostSchema  # That's it. Really.
end

# Use it
class PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    respond_with query(Post.all)
  end

  def create
    respond_with Post.create(action_params), status: :created
  end
end
```

Notice what's _not_ there? No validation code. No serialization logic. No query building. No pagination. No filter parsing.

Just a description of your data.

## What you get for free

From that code above, you automatically get:

- ✅ Full CRUD endpoints (`GET`, `POST`, `PATCH`, `DELETE`)
- ✅ Filtering: `GET /posts?filter[published]=true`
- ✅ Sorting: `GET /posts?sort[created_at]=desc`
- ✅ Pagination: `GET /posts?page[number]=2&page[size]=25`
- ✅ Input validation with detailed errors
- ✅ Output validation ensuring consistency
- ✅ Consistent JSON responses with root keys
- ✅ OpenAPI 3.1 specification
- ✅ TypeScript types
- ✅ Zod validation schemas

## How does it work?

It builds on what Rails already gives you.

Your database already knows about types — `title` is a string, `published` is a boolean, and fields marked `null: false` are required. Rails also knows which attributes are enums, including all their allowed values.

Apiwork pulls this information from your models and tries to inherit as much as possible, though you can manually specify it as well. Building on these definitions, when you mark an attribute as `writable: true`, it becomes available in your API inputs with the correct type automatically. When you mark it `filterable: true`, you get filter operators appropriate for that type — strings get `contains`, numbers get `greater_than`, enums get `in` or `equals`, etc.

## It's built for Rails developers

If you know Rails, you already know most of Apiwork:

- Routes look like Rails routes (because they use Rails routes)
- Conventions work like Rails conventions (`Api::V1::PostsController` lives in `app/controllers/api/v1/`)
- Models are just ActiveRecord models
- Controllers are just Rails controllers with a few helpers

No new paradigms to learn. No fighting the framework. Just Rails, but better at APIs.

## Built on Rails native features

Apiwork doesn't reinvent Rails - it extends it.

**Database types become API types:**
Your database column types (`string`, `integer`, `boolean`, `datetime`) map directly to API parameter types. Required fields (`null: false`) automatically become required in your API inputs.

**Native nested attributes:**
When you mark an association as `writable: true`, Apiwork expects your model to have `accepts_nested_attributes_for` configured. It then uses Rails' native nested attributes - no custom implementation.

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end

class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title, writable: true
  has_many :comments,
    schema: CommentSchema,
    writable: true  # Requires accepts_nested_attributes_for in model
end

# Now you can POST (API sends camelCase):
{
  "post": {
    "title": "My Post",
    "comments": [
      { "body": "Great post!" },
      { "id": 123, "_destroy": true }
    ]
  }
}
```

Apiwork transforms `comments` → `comments_attributes` internally before passing to Rails. You just use the association name in your API requests.

## Key concepts

Apiwork has four main DSL surfaces:

### 1. API Definition (`Apiwork::API.draw`)

Define your routes and API structure:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts do
    resources :comments

    member do
      patch :publish
    end
  end
end
```

This creates:

- Standard CRUD routes
- Nested resource routes
- Custom member actions

### 2. Schemas (`Apiwork::Schema::Base`)

Define what your data looks like and how it can be queried:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
  attribute :published, filterable: true, writable: true

  has_many :comments, schema: CommentSchema
end
```

Schemas control:

- Serialization (what fields appear in responses)
- Query capabilities (which fields can be filtered/sorted)
- Writability (which fields accept user input)
- Associations (how resources relate)

### 3. Contracts (`Apiwork::Contract::Base`)

Define and validate API inputs and outputs:

```ruby
class PostContract < Apiwork::Contract::Base
  schema PostSchema

  action :create do
    input do
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, default: false
    end
  end
end
```

Contracts ensure:

- Input validation (type checking, required fields)
- Output validation (responses match expectations)
- Documentation (OpenAPI knows exact shapes)

### 4. Controller Helpers

Integrate Apiwork into your Rails controllers:

```ruby
class PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    # query() applies filter, sort, pagination from params
    posts = query(Post.all)

    # respond_with() serializes and wraps response
    respond_with posts
  end

  def create
    # action_params provides validated, transformed params
    post = Post.create(action_params)
    respond_with post, status: :created
  end
end
```

## Data flow

Here's how a request flows through Apiwork:

```
1. Request arrives
   GET /api/v1/posts?filter[published]=true&sort[created_at]=desc&page[number]=2
   ↓
2. Routes match to controller action
   Api::V1::PostsController#index
   ↓
3. Controller uses query() helper
   - Applies filter[published]=true
   - Applies sort[created_at]=desc
   - Applies pagination
   - Returns ActiveRecord::Relation
   ↓
4. Controller uses respond_with()
   - Executes query
   - Serializes each post using PostSchema
   - Wraps in root key: { posts: [...] }
   - Validates output against PostContract
   - Returns JSON response
   ↓
5. Response sent
   {
     "ok": true,
     "posts": [
       { "id": 1, "title": "...", "body": "...", "published": true },
       ...
     ],
     "meta": {
       "page": { "current": 2, "next": 3, "prev": 1, "total": 10 }
     }
   }
```

For write operations (POST, PATCH):

```
1. Request arrives
   POST /api/v1/posts
   { "post": { "title": "New post", "body": "Content" } }
   ↓
2. Before action: Input validation
   - PostContract validates input
   - Checks types, required fields
   - Returns 422 if invalid
   ↓
3. Controller action executes
   - action_params provides validated data
   - Controller creates/updates record
   ↓
4. Response serialized and validated
   - PostSchema serializes the record
   - PostContract validates output
   - Returns 201 Created
   ↓
5. Response sent
   {
     "ok": true,
     "post": {
       "id": 1,
       "title": "New post",
       "body": "Content",
       "published": false
     }
   }
```

## When should you use Apiwork?

**Use it if:**

- You're building a REST API (not GraphQL)
- You want your frontend and backend to stay in sync
- You're tired of writing the same boilerplate
- You want filtering/sorting/pagination without writing it yourself
- You value convention over configuration

**Maybe not if:**

- Your API is extremely custom and doesn't fit REST patterns
- You have very simple endpoints and don't need structure
- You prefer writing everything explicitly

But honestly? Try it. It's just Rails. If you don't like it, you can always rip it out.

## How is this different from...?

**Active Model Serializers?**
AMS handles serialization. Apiwork handles serialization _and_ validation _and_ querying _and_ documentation. It's the whole stack.

**Grape?**
Similar idea, but Apiwork uses Rails conventions instead of Grape's DSL. If you're already in Rails, Apiwork feels more natural.

**JSON:API (jsonapi-rb)?**
JSON:API is a strict specification. Apiwork is more flexible - you get structure without being forced into a specific JSON format.

**Just writing controllers?**
You _can_ write everything by hand. But then you write filtering logic. And pagination. And validation. And serialization. And OpenAPI specs. And TypeScript types. And keep them all in sync.

Apiwork does all that for you.

## Next steps

Ready to start? Here's your path:

1. **[Installation](./installation.md)** - Set up Apiwork in your Rails app
2. **[Quick Start](./quick-start.md)** - Build your first API endpoint
3. **[Core Concepts](./core-concepts.md)** - Understand the architecture deeply

Or jump directly to specific topics:

- [API Definition](../api-definition/introduction.md) - Define routes
- [Schemas](../schemas/introduction.md) - Define data models
- [Contracts](../contracts/introduction.md) - Define validation
- [Controllers](../controllers/introduction.md) - Integrate into Rails
