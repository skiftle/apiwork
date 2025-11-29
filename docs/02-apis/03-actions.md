# Custom Actions

Beyond CRUD, you can define custom actions using `member` and `collection` blocks.

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

| Action | Method | Path |
|--------|--------|------|
| publish | PATCH | /posts/:id/publish |
| archive | PATCH | /posts/:id/archive |
| preview | GET | /posts/:id/preview |

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

| Action | Method | Path |
|--------|--------|------|
| search | GET | /posts/search |
| bulk_create | POST | /posts/bulk_create |
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

## Action Metadata

Add metadata for documentation:

```ruby
resources :posts do
  describe :publish,
    summary: "Publish a draft post",
    description: "Changes post status from draft to published",
    tags: ["Publishing"],
    deprecated: false,
    operation_id: "publishPost"

  member do
    patch :publish
  end
end
```

This metadata is used when generating OpenAPI specs.
