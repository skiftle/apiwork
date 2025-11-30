---
order: 3
---

# Custom Actions

Beyond the standard CRUD endpoints that come automatically from a `resources` declaration, you can extend a resource with custom behaviour using `member` and `collection` blocks. These allow you to define additional routes tied to the resource—such as publish, archive or search operations—while keeping the structure of the API clear and organised. Just like `resources`, these blocks behave the same way as their Rails counterparts.

## Member Actions

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

## Collection Actions

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

## HTTP Verbs

Available verbs: `get`, `post`, `patch`, `put`, `delete`

```ruby
member do
  get :preview      # Read-only operation
  patch :publish    # Update state
  post :duplicate   # Create something new
  delete :archive   # Remove/archive
end
```

## Shorthand

Multiple actions with the same verb:

```ruby
member do
  patch :publish, :archive, :approve
end

collection do
  get :drafts, :published, :archived
end
```

## Actions on Nested Resources

```ruby
resources :posts do
  resources :comments do
    member do
      patch :approve
    end

    collection do
      get :recent
    end
  end
end
```

Generates `/posts/:post_id/comments/:id/approve` and `/posts/:post_id/comments/recent`.
