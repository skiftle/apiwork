# Routing Options

A complete reference of all options available for `resources` and `resource`.

## Basic options

### only

Limit which actions to generate:

```ruby
resources :posts, only: [:index, :show]
resources :users, only: :show
```

Available actions:
- `index` - List resources
- `show` - Show one resource
- `create` - Create a resource
- `update` - Update a resource
- `destroy` - Delete a resource

### except

Generate all actions except these:

```ruby
resources :posts, except: [:destroy]
resources :users, except: [:create, :update, :destroy]  # Read-only
```

Can't use both `only` and `except` - choose one.

## Override options

### controller

Use a different controller (Rails-style path):

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

Routes to the specified controller instead of the conventional one.

### contract

Use a different contract (Rails-style path):

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

Useful for:
- Different validation for public vs admin
- Shared contracts across resources

```ruby
# Public API - limited fields
resources :posts, contract: 'public_post'

# Admin API - full access
resources :posts, contract: 'admin/post'
```

## Concerns

Share routing patterns:

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

resources :posts, concerns: [:commentable, :publishable]
resources :articles, concerns: [:commentable, :publishable]
```

See [Advanced: Concerns](./advanced.md#concerns) for details.

## with_options

Apply options to multiple resources:

```ruby
with_options only: [:index, :show] do
  resources :posts
  resources :users
  resources :comments
end
```

All three resources get `only: [:index, :show]`.

You can nest `with_options`:

```ruby
with_options contract: 'public_post' do
  with_options only: [:index, :show] do
    resources :posts
    resources :articles
  end
end
```

See [Advanced: with_options](./advanced.md#with_options) for more examples.

## Combining options

You can combine any options:

```ruby
resources :posts,
  only: [:index, :show],
  controller: 'articles',
  contract: 'public_post',
  concerns: [:commentable]
```

This creates:
- Actions: only index and show
- Controller: `Api::V1::ArticlesController`
- Contract: `Api::V1::PublicPostContract`
- Adds routes from commentable concern

## Common patterns

### Read-only API

```ruby
resources :posts, only: [:index, :show]
resources :users, only: [:index, :show]
resources :comments, only: [:index, :show]
```

Or with `with_options`:

```ruby
with_options only: [:index, :show] do
  resources :posts
  resources :users
  resources :comments
end
```

### Admin API with different contract

```ruby
# Public API
resources :posts, contract: 'public_post'

# Admin API (nested resources)
resources :admin_posts, contract: 'admin/post', controller: 'admin/posts'
```

### Shared contract across resources

```ruby
# Both posts and articles use the same contract
resources :posts, contract: 'content'
resources :articles, contract: 'content'
```

### Concerns for reusable patterns

```ruby
concern :auditable do
  resources :audit_logs, only: [:index, :show]
end

concern :publishable do
  member do
    patch :publish
    patch :unpublish
  end
end

# Apply to multiple resources
resources :posts, concerns: [:auditable, :publishable]
resources :articles, concerns: [:auditable, :publishable]
```

## What Apiwork does NOT support

These Rails routing features are **not supported** in Apiwork:

- ❌ `path:` - Cannot change URL path
- ❌ `param:` - Cannot change ID parameter name
- ❌ `module:` - Use `controller:` with nested path instead
- ❌ `shallow:` - No shallow nesting support
- ❌ `shallow_path:` / `shallow_prefix:` - No shallow options
- ❌ `defaults:` - No default parameters
- ❌ `constraints:` - No route constraints
- ❌ `desc:` / `tags:` - No inline documentation options

If you need custom routing behavior, use nested resources or custom actions instead.

## Next steps

- **[Advanced](./advanced.md)** - with_options, concerns, and DRY patterns
- **[Introduction](./introduction.md)** - Back to API definition overview
- **[Resources](./resources.md)** - Resource routing patterns
- **[Actions](./actions.md)** - Custom actions
