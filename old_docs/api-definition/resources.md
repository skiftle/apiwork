# Resources

Resources are the heart of your API definition. They map HTTP verbs to controller actions and create RESTful URLs.

If you've used Rails routing, this will feel completely natural. Because it *is* Rails routing.

## Basic resources

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end
```

This single line creates 5 routes:

| Method | Path | Controller Action | Purpose |
|--------|------|------------------|---------|
| GET | `/api/v1/posts` | `index` | List all posts |
| GET | `/api/v1/posts/:id` | `show` | Show one post |
| POST | `/api/v1/posts` | `create` | Create a post |
| PATCH/PUT | `/api/v1/posts/:id` | `update` | Update a post |
| DELETE | `/api/v1/posts/:id` | `destroy` | Delete a post |

All routed to `Api::V1::PostsController`.

## Limiting actions

Don't need all 5 actions? Use `only` or `except`:

```ruby
# Only list and show
resources :posts, only: [:index, :show]

# Everything except delete
resources :posts, except: [:destroy]

# Just one action
resources :posts, only: :show
```

This is useful for:
- **Read-only APIs**: `only: [:index, :show]`
- **Write-only APIs**: `only: [:create]`
- **No deletion**: `except: [:destroy]`

## Singular resources

Some resources don't have multiple instances. Like a user's account settings, or a profile.

```ruby
resource :account  # Note: singular
```

This creates 4 routes (no `index`):

| Method | Path | Controller Action |
|--------|------|------------------|
| GET | `/api/v1/account` | `show` |
| POST | `/api/v1/account` | `create` |
| PATCH/PUT | `/api/v1/account` | `update` |
| DELETE | `/api/v1/account` | `destroy` |

Notice:
- No `:id` parameter (there's only one)
- No `index` action
- Still routed to `Api::V1::AccountsController` (plural controller name)

### When to use singular resources

```ruby
# User has one profile
resource :profile

# User has one account
resource :account

# App has one config
resource :config

# Post has one metadata
resource :metadata
```

**Don't use it for:**
```ruby
# BAD - users can have multiple addresses
resource :address  # This suggests only one address

# GOOD - plural resources
resources :addresses
```

## Nested resources

Resources often belong to other resources. Posts have comments. Users have posts.

```ruby
resources :posts do
  resources :comments
end
```

This creates nested routes:

```
GET    /api/v1/posts/:post_id/comments
GET    /api/v1/posts/:post_id/comments/:id
POST   /api/v1/posts/:post_id/comments
PATCH  /api/v1/posts/:post_id/comments/:id
DELETE /api/v1/posts/:post_id/comments/:id
```

Your controller gets both IDs in params:

```ruby
class Api::V1::CommentsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    post = Post.find(params[:post_id])
    respond_with query(post.comments)
  end

  def create
    post = Post.find(params[:post_id])
    comment = post.comments.create(action_params)
    respond_with comment, status: :created
  end
end
```

### Multiple levels of nesting

You can nest resources multiple levels deep:

```ruby
resources :users do
  resources :posts do
    resources :comments
  end
end
```

This creates:

```
GET /api/v1/users/:user_id/posts/:post_id/comments
```

But **be careful**. Deep nesting makes URLs unwieldy and controllers complex.

**Better approach** - keep nesting shallow:

```ruby
resources :users do
  resources :posts
end

resources :posts do
  resources :comments
end
```

Now you have:
- `POST /api/v1/users/:user_id/posts` - Create user's post
- `POST /api/v1/posts/:post_id/comments` - Create post's comment
- `GET /api/v1/posts/:post_id/comments/:id` - Get comment

Clear ownership, manageable URLs.

## Overriding conventions

Sometimes you need to break from conventions. Apiwork gives you escape hatches.

### Custom contract

By default, `resources :posts` expects `Api::V1::PostContract`. Override it with Rails-style paths:

```ruby
# Relative path - adds to current namespace
resources :posts, contract: 'public_post'
# → Api::V1::PublicPostContract

# With nested namespace
resources :posts, contract: 'admin/post'
# → Api::V1::Admin::PostContract

# Absolute path (starts with /)
resources :posts, contract: '/custom/post'
# → Custom::PostContract
```

See [Routing Options: contract](./routing-options.md#contract) for details.

### Custom controller

By default, `resources :posts` expects `Api::V1::PostsController`. Override it with Rails-style paths:

```ruby
# Relative path - adds to current namespace
resources :posts, controller: 'articles'
# → Api::V1::ArticlesController

# With nested namespace
resources :posts, controller: 'admin/posts'
# → Api::V1::Admin::PostsController

# Absolute path (starts with /)
resources :posts, controller: '/admin/posts'
# → Admin::PostsController
```

See [Routing Options: controller](./routing-options.md#controller) for details.

## Combining options

You can combine any options:

```ruby
resources :posts,
  only: [:index, :show],
  controller: 'articles',
  contract: 'public_post'
```

This creates:
- Routes: `GET /api/v1/posts` and `GET /api/v1/posts/:id`
- Controller: `Api::V1::ArticlesController`
- Contract: `Api::V1::PublicPostContract`

## Namespacing

Your API path automatically namespaces everything:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end
# Routes → /api/v1/posts
# Controller → Api::V1::PostsController
# Contract → Api::V1::PostContract
```

Change the path, everything updates:

```ruby
Apiwork::API.draw '/api/v2' do
  resources :posts
end
# Routes → /api/v2/posts
# Controller → Api::V2::PostsController
# Contract → Api::V2::PostContract
```

## Resource blocks

Everything inside a `resources` block is scoped to that resource:

```ruby
resources :posts do
  # Custom actions (see Actions guide)
  member do
    patch :publish
  end

  collection do
    get :drafts
  end

  # Nested resources
  resources :comments
end
```

## Multiple resources

Define multiple resources in one file:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
  resources :users
  resources :comments

  resource :account
  resource :profile
end
```

Each gets its own controller and contract.

## Common patterns

### Public API - read only

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts, only: [:index, :show]
  resources :articles, only: [:index, :show]
  resources :tags, only: [:index, :show]
end
```

Perfect for public APIs where users can browse but not modify.

### Admin API with different contract

```ruby
Apiwork::API.draw '/api/v1' do
  # Public API - limited fields
  resources :posts, contract: 'public_post'

  # Admin API - full access
  resources :admin_posts,
    contract: 'admin/post',
    controller: 'admin/posts'
end
```

### Versioned APIs

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts, only: [:index, :show]
end

# config/apis/v2.rb
Apiwork::API.draw '/api/v2' do
  resources :posts  # Full CRUD in v2
  resources :articles  # New resource in v2
end
```

Each version has separate controllers and contracts.

### Nested resources

```ruby
resources :users do
  resources :posts do
    resources :comments
  end
end
```

Creates:
- `POST /api/v1/users/:user_id/posts` - Create user's post
- `POST /api/v1/users/:user_id/posts/:post_id/comments` - Create post's comment
- `GET /api/v1/users/:user_id/posts/:post_id/comments/:id` - Get comment

## What about singular routes?

Rails lets you define singular routes with `get`, `post`, etc. Apiwork doesn't support that directly.

Why? Because Apiwork is designed for REST APIs with contracts, schemas, and documentation. Singular routes don't fit that pattern.

If you need a one-off endpoint, use a custom action:

```ruby
resources :posts do
  collection do
    get :search  # GET /api/v1/posts/search
  end
end
```

Or use a singular resource:

```ruby
resource :search, only: :show  # GET /api/v1/search
```

This keeps everything consistent with contracts and schemas.

## What Apiwork does NOT support

These Rails routing features are **not supported** in Apiwork:

- ❌ `path:` - Cannot change URL path (resource name determines path)
- ❌ `param:` - Cannot change ID parameter name (always `:id`)
- ❌ `shallow:` / `shallow_path:` / `shallow_prefix:` - No shallow nesting support
- ❌ `module:` - Use `controller:` with nested path instead
- ❌ `namespace do` - Not yet supported (use nested controllers instead)
- ❌ `defaults:` - No default parameters
- ❌ `constraints:` - No route constraints

If you need different URL paths or parameter names, use custom actions or design your resource structure differently.

## Next steps

- **[Actions](./actions.md)** - Custom member and collection actions
- **[Configuration](./configuration.md)** - Schema endpoints and documentation
- **[Routing Options](./routing-options.md)** - All available options reference
- **[Advanced](./advanced.md)** - with_options and concerns
