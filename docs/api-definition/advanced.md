# Advanced Routing

Once your API grows, you'll want ways to keep your routing file DRY and maintainable.

Apiwork gives you two powerful tools: `with_options` and `concerns`.

## with_options

When multiple resources share the same options, use `with_options`:

```ruby
Apiwork::API.draw '/api/v1' do
  with_options only: [:index, :show] do
    resources :posts
    resources :users
    resources :comments
  end
end
```

This is equivalent to:

```ruby
resources :posts, only: [:index, :show]
resources :users, only: [:index, :show]
resources :comments, only: [:index, :show]
```

### Nested with_options

You can nest `with_options` blocks:

```ruby
with_options controller: 'admin/posts' do
  with_options only: [:index, :show] do
    resources :posts
    resources :articles
  end

  resources :drafts  # Uses controller: 'admin/posts', all actions
end
```

### Common use cases

**Read-only resources:**

```ruby
with_options only: [:index, :show] do
  resources :posts
  resources :users
  resources :comments
  resources :tags
end
```

**Custom contract for multiple resources:**

```ruby
with_options contract: 'public_post' do
  resources :blog_posts
  resources :articles
  resources :news_items
end
```

**Nested controllers:**

```ruby
with_options controller: 'admin/posts' do
  resources :published_posts
  resources :draft_posts
  resources :archived_posts
end
```

### How with_options merges

Options are merged from outer to inner blocks:

```ruby
with_options only: [:index, :show, :create] do
  with_options except: [:create] do
    resources :posts  # Gets only: [:index, :show, :create], except: [:create]
    # Result: only index and show
  end
end
```

Resource-specific options override `with_options`:

```ruby
with_options only: [:index, :show] do
  resources :posts  # Gets only: [:index, :show]
  resources :users, only: [:index, :show, :create]  # Overrides to add create
end
```

## Concerns

Extract reusable routing patterns into concerns:

```ruby
concern :commentable do
  resources :comments
end

resources :posts, concerns: :commentable
resources :articles, concerns: :commentable
```

This expands to:

```ruby
resources :posts do
  resources :comments
end

resources :articles do
  resources :comments
end
```

### Multiple concerns

Apply multiple concerns to one resource:

```ruby
concern :commentable do
  resources :comments
end

concern :publishable do
  member do
    patch :publish
    patch :unpublish
  end
end

concern :archivable do
  member do
    patch :archive
    patch :unarchive
  end
end

resources :posts, concerns: [:commentable, :publishable, :archivable]
```

### Concerns with custom actions

Concerns can include member and collection actions:

```ruby
concern :commentable do
  resources :comments do
    member do
      patch :approve
      patch :reject
    end

    collection do
      get :pending
    end
  end
end

resources :posts, concerns: :commentable
resources :articles, concerns: :commentable
```

Both `posts` and `articles` now have:
- `GET /api/v1/posts/:post_id/comments`
- `PATCH /api/v1/posts/:post_id/comments/:id/approve`
- `GET /api/v1/posts/:post_id/comments/pending`

### Defining concerns inline

Define concerns right in your routing file:

```ruby
Apiwork::API.draw '/api/v1' do
  concern :commentable do
    resources :comments do
      member do
        patch :approve
      end
    end
  end

  concern :publishable do
    member do
      patch :publish
      patch :unpublish
    end
  end

  resources :posts, concerns: [:commentable, :publishable]
  resources :articles, concerns: [:commentable, :publishable]
end
```

### Common concern patterns

**Publishable resources:**

```ruby
concern :publishable do
  member do
    patch :publish
    patch :unpublish
  end
end

resources :posts, concerns: :publishable
resources :articles, concerns: :publishable
resources :pages, concerns: :publishable
```

**Auditable resources:**

```ruby
concern :auditable do
  resources :audit_logs, only: [:index, :show]
end

resources :posts, concerns: :auditable
resources :users, concerns: :auditable
```

**Rateable resources:**

```ruby
concern :rateable do
  resources :ratings, only: [:index, :create, :destroy]
end

resources :posts, concerns: :rateable
resources :articles, concerns: :rateable
```

**Taggable resources:**

```ruby
concern :taggable do
  resources :tags, only: [:index] do
    collection do
      post :bulk_add
      delete :bulk_remove
    end
  end
end

resources :posts, concerns: :taggable
resources :articles, concerns: :taggable
```

## Combining with_options and concerns

Use both together for maximum DRY:

```ruby
Apiwork::API.draw '/api/v1' do
  concern :publishable do
    member do
      patch :publish
      patch :unpublish
    end
  end

  # Read-only resources with publish actions
  with_options only: [:index, :show], concerns: :publishable do
    resources :posts
    resources :articles
    resources :pages
  end
end
```

## Organizing large routing files

As your API grows, organize by domain:

### Strategy 1: Multiple API files

Split into separate files - they all merge into one API:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  # Base configuration
  schema :openapi
end

# config/apis/v1/blog.rb
Apiwork::API.draw '/api/v1' do
  resources :posts do
    resources :comments
  end
  resources :tags
end

# config/apis/v1/users.rb
Apiwork::API.draw '/api/v1' do
  resources :users do
    resource :profile
  end
  resource :account
end
```

Rails auto-loads files in `config/apis/`, and they all merge into the same `/api/v1` API.

### Strategy 2: Group with comments

```ruby
Apiwork::API.draw '/api/v1' do
  schema :openapi

  # ===== Blog Resources =====

  resources :posts do
    resources :comments
  end
  resources :tags
  resources :categories

  # ===== User Resources =====

  resources :users do
    resource :profile
  end
  resource :account

  # ===== Admin Resources =====

  with_options controller: 'admin/posts' do
    resources :published_posts
    resources :draft_posts
  end
end
```

### Strategy 3: Use concerns for domains

```ruby
Apiwork::API.draw '/api/v1' do
  # Define domain-specific concerns
  concern :blog_routes do
    resources :posts do
      resources :comments
    end
    resources :tags
  end

  concern :user_routes do
    resources :users do
      resource :profile
    end
  end

  # Apply them
  concerns :blog_routes
  concerns :user_routes
end
```

## Conditional routing

Load routes based on environment or feature flags:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
  resources :users

  # Development only
  if Rails.env.development?
    resources :debug_logs
    resources :test_data
  end

  # Feature flags
  if ENV['FEATURE_COMMENTS'] == 'enabled'
    resources :comments
  end
end
```

This is useful for:
- **Feature flags**: Enable routes for beta features
- **Development tools**: Debug endpoints only in dev
- **Gradual rollouts**: Enable routes for specific environments

## Multiple APIs in one app

Define completely separate APIs:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts, only: [:index, :show]
end

# config/apis/v2.rb
Apiwork::API.draw '/api/v2' do
  resources :posts  # Full CRUD
  resources :articles  # New in v2
end

# config/apis/admin.rb
Apiwork::API.draw '/api/admin' do
  resources :users
  resources :posts
end
```

Each API is completely independent:
- Separate namespaces (`Api::V1`, `Api::V2`, `Api::Admin`)
- Separate controllers, contracts, schemas
- Separate OpenAPI specs

## Debugging routes

See all routes for your API:

```bash
rails routes | grep api/v1
```

Or fetch the OpenAPI schema:

```bash
curl http://localhost:3000/api/v1/.schema/openapi | jq '.paths | keys'
```

This shows all defined paths.

## What Apiwork does NOT support

These Rails routing features are **not supported** in Apiwork:

- ❌ `namespace do` - Use nested controllers with `controller:` option instead
- ❌ `scope` blocks - Not supported
- ❌ `module:` option - Use `controller:` with nested path instead
- ❌ `defaults:` - No default parameters
- ❌ `constraints:` - No route constraints

If you need these features, use the available options (`only`, `except`, `controller`, `contract`, `with_options`, `concerns`) to achieve your goals.

## Next steps

Now you've mastered API definition. Continue to:

- **[Schemas](../schemas/introduction.md)** - Define your data models
- **[Contracts](../contracts/introduction.md)** - Define validation and actions
- **[Controllers](../controllers/introduction.md)** - Implement your endpoints
- **[Querying](../querying/introduction.md)** - Filtering, sorting, pagination

Or revisit:

- **[Introduction](./introduction.md)** - API definition basics
- **[Resources](./resources.md)** - Resource patterns
- **[Actions](./actions.md)** - Custom actions
- **[Configuration](./configuration.md)** - Schema endpoints
- **[Routing Options](./routing-options.md)** - All options reference
