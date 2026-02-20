---
order: 2
---

# Resources

Resources define your API endpoints. They follow Rails routing conventions:

- Define which endpoints exist
- Link each endpoint to its [contract](../contracts/introduction.md)
- Form part of the API's metadata for [exports](./exports.md)

## Path and Namespace

The path you pass to `define` determines two things:

1. **Mount point** — where your routes live (`/api/v1/posts`)
2. **Namespace** — where Apiwork looks for controllers and contracts

```ruby
Apiwork::API.define '/api/v1' do
  resources :posts
end

# Path: /api/v1 maps to namespace Api::V1
# Controller: Api::V1::PostsController
# Contract: Api::V1::PostContract
# Representation: Api::V1::PostRepresentation
```

The conversion is straightforward: `/api/v1` becomes `Api::V1`.

For APIs without a prefix:

```ruby
Apiwork::API.define '/' do
  resources :posts
end

# Routes at /posts
# No namespace prefix
```

## Multiple APIs

You can define multiple APIs, each completely independent:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  resources :posts, only: [:index, :show]
end

# config/apis/api_v2.rb
Apiwork::API.define '/api/v2' do
  resources :posts
  resources :articles
end
```

Each API has its own namespace with controllers, contracts, and representations.

## Plural Resources

```ruby
resources :posts
```

Generates five CRUD actions:

| Action  | Method | Path       |
| ------- | ------ | ---------- |
| index   | GET    | /posts     |
| show    | GET    | /posts/:id |
| create  | POST   | /posts     |
| update  | PATCH  | /posts/:id |
| destroy | DELETE | /posts/:id |

## Singular Resources

```ruby
resource :account
```

For resources where there's only one (like the current user's account):

| Action  | Method | Path     |
| ------- | ------ | -------- |
| show    | GET    | /account |
| create  | POST   | /account |
| update  | PATCH  | /account |
| destroy | DELETE | /account |

No `index` action, no `:id` in the path. The controller is still plural (`AccountsController`) — this is standard Rails `resource` behavior.

## Limiting Actions

### only

```ruby
resources :posts, only: [:index, :show]
```

Only generates the specified actions.

### except

```ruby
resources :posts, except: [:destroy]
```

Generates all actions except the specified ones.

## Nested Resources

```ruby
resources :posts do
  resources :comments
end
```

Generates routes like `/posts/:post_id/comments` and `/posts/:post_id/comments/:id`.

## Contract Inference

Apiwork infers the contract from the resource name in singular form:

```ruby
resources :posts      # uses PostContract
resources :comments   # uses CommentContract
resource :account     # uses AccountContract
```

::: tip
If you have both `resources :user` and `resources :users`, they would both try to use `UserContract`. Use the `contract:` option to disambiguate:

```ruby
resources :user, contract: 'current_user'   # uses CurrentUserContract
resources :users                            # uses UserContract
```
:::

## Custom Contract

Override the inferred contract:

```ruby
resources :posts, contract: 'public_post'
# Uses Api::V1::PublicPostContract

resources :posts, contract: 'admin/post'
# Uses Api::V1::Admin::PostContract
```

## Custom Controller

```ruby
resources :posts, controller: 'articles'
# Uses Api::V1::ArticlesController

resources :posts, controller: 'admin/posts'
# Uses Api::V1::Admin::PostsController
```

Both `contract:` and `controller:` work the same way as Rails' routing options.

## Custom Actions

Add custom actions with `member` and `collection` blocks.

### Member Actions

Member actions operate on a single resource (they have an `:id`):

```ruby
resources :posts do
  member do
    patch :publish
    patch :archive
    get :preview
  end
end
```

| Action  | Method | Path               |
| ------- | ------ | ------------------ |
| publish | PATCH  | /posts/:id/publish |
| archive | PATCH  | /posts/:id/archive |
| preview | GET    | /posts/:id/preview |

### Collection Actions

Collection actions operate on the entire collection (no `:id`):

```ruby
resources :posts do
  collection do
    get :search
    post :bulk_create
    delete :bulk_destroy
  end
end
```

| Action       | Method | Path                |
| ------------ | ------ | ------------------- |
| search       | GET    | /posts/search       |
| bulk_create  | POST   | /posts/bulk_create  |
| bulk_destroy | DELETE | /posts/bulk_destroy |

### HTTP Verbs

Available verbs: `get`, `post`, `patch`, `put`, `delete`

```ruby
member do
  get :preview      # Read-only operation
  patch :publish    # Update state
  post :duplicate   # Create something new
  delete :archive   # Remove/archive
end
```

### Shorthand

Multiple actions with the same verb:

```ruby
member do
  patch :publish, :archive, :approve
end

collection do
  get :drafts, :published, :archived
end
```

## Concerns

Concerns extract reusable routing patterns.

### Defining a Concern

```ruby
Apiwork::API.define '/api/v1' do
  concern :auditable do
    member do
      get :audit_log
    end
  end

  resources :posts, concerns: [:auditable]
  resources :comments, concerns: [:auditable]
end
```

Both posts and comments now have a `GET /posts/:id/audit_log` and `GET /comments/:id/audit_log` endpoint.

### Multiple Concerns

```ruby
concern :auditable do
  member do
    get :audit_log
  end
end

concern :searchable do
  collection do
    get :search
  end
end

resources :posts, concerns: [:auditable, :searchable]
```

### Concerns with Nested Resources

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

resources :posts, concerns: [:commentable]
resources :articles, concerns: [:commentable]
```

Both posts and articles now have nested comment routes with approve, reject, and pending actions.

#### See also

- [API::Base reference](../../../reference/api/base.md) — `resources`, `resource`, `concern`, and routing options
