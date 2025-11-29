# Resources

Resources define the endpoints for your API.

## Plural Resources

```ruby
resources :posts
```

Generates five CRUD actions:

| Action | Method | Path |
|--------|--------|------|
| index | GET | /posts |
| show | GET | /posts/:id |
| create | POST | /posts |
| update | PATCH | /posts/:id |
| destroy | DELETE | /posts/:id |

## Singular Resources

```ruby
resource :account
```

For resources where there's only one (like the current user's account):

| Action | Method | Path |
|--------|--------|------|
| show | GET | /account |
| create | POST | /account |
| update | PATCH | /account |
| destroy | DELETE | /account |

No `index` action, no `:id` in the path. The controller is still plural: `AccountsController`.

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
resources :posts      # → PostContract
resources :comments   # → CommentContract
resource :account     # → AccountContract
```

If you have both `resources :user` and `resources :users`, they would both try to use `UserContract`. Use the `contract:` option to disambiguate:

```ruby
resources :user, contract: 'current_user'   # → CurrentUserContract
resources :users                            # → UserContract
```

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
