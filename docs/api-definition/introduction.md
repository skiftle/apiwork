# API Definition

Your API definition is where you declare what endpoints exist and how they're organized.

It looks almost exactly like Rails routes. Because it *is* Rails routes, with a thin wrapper.

## Mounting your APIs

First, mount Apiwork in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Apiwork.routes => '/'
end
```

This mounts **all** API definitions from `config/apis/`. Every file in that directory is automatically loaded and merged into your routes.

## The basics

Create `config/apis/v1.rb`:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end
```

This single line gives you:
- `GET /api/v1/posts` → `Api::V1::PostsController#index`
- `GET /api/v1/posts/:id` → `Api::V1::PostsController#show`
- `POST /api/v1/posts` → `Api::V1::PostsController#create`
- `PATCH /api/v1/posts/:id` → `Api::V1::PostsController#update`
- `DELETE /api/v1/posts/:id` → `Api::V1::PostsController#destroy`

If you know Rails routing, you already know this.

## The path determines everything

The path you pass to `Apiwork::API.draw` is **required** and does two critical things:

**1. Sets the URL prefix:**
```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end
# Routes: GET /api/v1/posts, POST /api/v1/posts, etc.
```

**2. Sets the namespace automatically:**
```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end
# Expects: Api::V1::PostsController
# Expects: Api::V1::PostContract
# Expects: Api::V1::PostSchema
```

Change the path, everything else follows:

```ruby
Apiwork::API.draw '/api/v2' do
  resources :posts
end
# Routes: /api/v2/posts
# Expects: Api::V2::PostsController, Api::V2::PostContract, etc.
```

### Using the root path

You can also mount at the root:

```ruby
Apiwork::API.draw '/' do
  resources :posts
end
# Routes: GET /posts, POST /posts, etc.
# Expects: Root::PostsController, Root::PostContract, Root::PostSchema
```

The path determines the namespace: `/api/v1` → `Api::V1`, `/` → `Root`.

This is convention over configuration. You can override controller/contract paths, but you rarely need to.

## Standard resources

Just like Rails, `resources` gives you the standard CRUD operations:

```ruby
resources :posts
```

This generates 5 routes:
- **index** - List all posts
- **show** - Show one post
- **create** - Create a post
- **update** - Update a post
- **destroy** - Delete a post

You can limit which actions to generate:

```ruby
resources :posts, only: [:index, :show]
resources :posts, except: [:destroy]
```

## Singular resources

For resources that don't have multiple instances:

```ruby
resource :account  # Note: singular
```

This gives you:
- `GET /api/v1/account` → `show`
- `POST /api/v1/account` → `create`
- `PATCH /api/v1/account` → `update`
- `DELETE /api/v1/account` → `destroy`

No `index` action. No `:id` parameter.

## Nested resources

Resources can be nested, just like Rails:

```ruby
resources :posts do
  resources :comments
end
```

This creates:
- `GET /api/v1/posts/:post_id/comments`
- `GET /api/v1/posts/:post_id/comments/:id`
- `POST /api/v1/posts/:post_id/comments`
- etc.

Your controller gets both `params[:post_id]` and `params[:id]`:

```ruby
class Api::V1::CommentsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    post = Post.find(params[:post_id])
    respond_with query(post.comments)
  end
end
```

## Custom actions

Beyond CRUD, you can add custom actions:

```ruby
resources :posts do
  member do
    patch :publish    # PATCH /api/v1/posts/:id/publish
    patch :archive    # PATCH /api/v1/posts/:id/archive
  end

  collection do
    get :drafts       # GET /api/v1/posts/drafts
    post :bulk_create # POST /api/v1/posts/bulk_create
  end
end
```

**Member actions** operate on a single resource (have `:id`).
**Collection actions** operate on the collection (no `:id`).

See [Actions](./actions.md) for all the details.

## Schema generation endpoints

Enable schema generation for your frontend:

```ruby
Apiwork::API.draw '/api/v1' do
  schema :openapi     # GET /api/v1/.schema/openapi
  schema :transport   # GET /api/v1/.schema/transport
  schema :zod         # GET /api/v1/.schema/zod

  resources :posts
end
```

Now you can generate TypeScript types, OpenAPI specs, and Zod schemas automatically.

See [Configuration](./configuration.md) for more options.

## Multiple API versions

Define multiple versions in separate files:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts
end

# config/apis/v2.rb
Apiwork::API.draw '/api/v2' do
  resources :posts
  resources :articles  # New in v2
end
```

Each version has its own:
- Mount point (`/api/v1`, `/api/v2`)
- Namespace (`Api::V1`, `Api::V2`)
- Controllers, contracts, schemas

## What's different from Rails routes?

Not much. But there are a few differences:

**1. Automatic contract resolution:**
Apiwork automatically finds and uses your contracts for validation.

**2. Schema generation:**
You can expose OpenAPI/TypeScript/Zod schemas.

**3. Simplified DSL:**
Only the most common routing patterns are supported. No crazy custom route matchers.

**4. API-first conventions:**
Routes are designed for JSON APIs, not HTML views.

But the core routing? That's pure Rails.

## Next steps

- **[Resources](./resources.md)** - Deep dive into resources and options
- **[Actions](./actions.md)** - Custom member and collection actions
- **[Configuration](./configuration.md)** - Schema endpoints and documentation
- **[Routing Options](./routing-options.md)** - only, except, and overrides
- **[Advanced](./advanced.md)** - with_options and concerns
