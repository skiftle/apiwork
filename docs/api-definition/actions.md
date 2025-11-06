# Actions

Beyond the standard CRUD operations, you'll often need custom actions. Like publishing a post, archiving an article, or searching users.

Apiwork gives you `member` and `collection` actions - just like Rails.

## Member actions

Member actions operate on a single resource. They need an `:id`.

```ruby
resources :posts do
  member do
    patch :publish
    patch :archive
  end
end
```

This creates:

```
PATCH /api/v1/posts/:id/publish
PATCH /api/v1/posts/:id/archive
```

Your controller implements them:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def publish
    post = Post.find(params[:id])
    post.update(published: true, published_at: Time.current)
    respond_with post
  end

  def archive
    post = Post.find(params[:id])
    post.update(archived: true, archived_at: Time.current)
    respond_with post
  end
end
```

### HTTP verbs for member actions

You can use any HTTP verb:

```ruby
member do
  get :preview      # GET /api/v1/posts/:id/preview
  patch :publish    # PATCH /api/v1/posts/:id/publish
  post :duplicate   # POST /api/v1/posts/:id/duplicate
  delete :archive   # DELETE /api/v1/posts/:id/archive
end
```

**Which verb to use?**

- **GET** - Fetching derived data (preview, stats, export)
- **PATCH** - Updating state (publish, archive, approve)
- **POST** - Creating something new (duplicate, fork, clone)
- **DELETE** - Removing something (archive, soft_delete)

General rule: If it changes the resource, use `PATCH`. If it creates something new, use `POST`.

## Collection actions

Collection actions operate on the entire collection. No `:id`.

```ruby
resources :posts do
  collection do
    get :drafts
    get :published
    post :bulk_create
  end
end
```

This creates:

```
GET  /api/v1/posts/drafts
GET  /api/v1/posts/published
POST /api/v1/posts/bulk_create
```

Your controller:

```ruby
def drafts
  posts = query(Post.where(published: false))
  respond_with posts
end

def published
  posts = query(Post.where(published: true))
  respond_with posts
end

def bulk_create
  posts = params[:posts].map { |attrs| Post.create(attrs) }
  respond_with posts, status: :created
end
```

### When to use collection actions

Collection actions are useful for:

- **Filtered views**: `drafts`, `published`, `archived`
- **Bulk operations**: `bulk_create`, `bulk_update`, `bulk_delete`
- **Search**: `search`
- **Exports**: `export`, `download`

But consider: Do you need a custom action, or can you use filters?

```ruby
# Custom action
collection do
  get :published
end
# GET /api/v1/posts/published

# vs. using filters
# GET /api/v1/posts?filter[published]=true
```

Filters are more flexible. Use custom actions when:
- The logic is complex (multiple conditions, joins)
- The URL reads better (`/drafts` vs `?filter[published]=false`)
- You want a dedicated contract with different validation

## Shorthand syntax

You can define actions in one line:

```ruby
resources :posts do
  member do
    patch :publish, :archive, :approve
  end

  collection do
    get :drafts, :published, :archived
  end
end
```

This is equivalent to:

```ruby
member do
  patch :publish
  patch :archive
  patch :approve
end

collection do
  get :drafts
  get :published
  get :archived
end
```

## Nested resource actions

Actions work on nested resources too:

```ruby
resources :posts do
  resources :comments do
    member do
      patch :approve
    end

    collection do
      get :pending
    end
  end
end
```

Creates:

```
PATCH /api/v1/posts/:post_id/comments/:id/approve
GET   /api/v1/posts/:post_id/comments/pending
```

Your controller gets both IDs:

```ruby
def approve
  post = Post.find(params[:post_id])
  comment = post.comments.find(params[:id])
  comment.update(approved: true)
  respond_with comment
end

def pending
  post = Post.find(params[:post_id])
  comments = query(post.comments.where(approved: false))
  respond_with comments
end
```

## Defining contracts for actions

Custom actions need contracts to define their inputs and outputs.

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema  # Auto-generates index, show, create, update, destroy

  # Custom action contract
  action :publish do
    # No input needed for this action
    output do
      param :id, type: :integer, required: true
      param :title, type: :string, required: true
      param :published, type: :boolean, required: true
      param :published_at, type: :datetime, required: true
    end
  end

  action :bulk_create do
    input do
      param :posts, type: :array, required: true, of: :object do
        param :title, type: :string, required: true
        param :body, type: :string, required: true
      end
    end

    output do
      param :posts, type: :array, required: true, of: :object do
        param :id, type: :integer, required: true
        param :title, type: :string, required: true
        param :body, type: :string, required: true
      end
    end
  end
end
```

See [Contracts](../contracts/actions.md) for detailed action contract documentation.

## Action naming conventions

Apiwork follows Rails naming conventions:

**Member action `patch :publish`:**
- Route: `PATCH /api/v1/posts/:id/publish`
- Controller method: `Api::V1::PostsController#publish`
- Contract action: `action :publish`

**Collection action `get :drafts`:**
- Route: `GET /api/v1/posts/drafts`
- Controller method: `Api::V1::PostsController#drafts`
- Contract action: `action :drafts`

Everything uses the same name. Simple.

## Common action patterns

### State transitions

```ruby
resources :posts do
  member do
    patch :publish
    patch :unpublish
    patch :archive
    patch :unarchive
  end
end
```

These map to state machine transitions in your model:

```ruby
class Post < ApplicationRecord
  include AASM  # Or any state machine gem

  aasm do
    state :draft, initial: true
    state :published
    state :archived

    event :publish do
      transitions from: :draft, to: :published
    end

    event :unpublish do
      transitions from: :published, to: :draft
    end

    event :archive do
      transitions from: [:draft, :published], to: :archived
    end
  end
end
```

Your controller just calls the event:

```ruby
def publish
  post = Post.find(params[:id])
  post.publish!  # State machine handles validation
  respond_with post
end
```

### Bulk operations

```ruby
resources :posts do
  collection do
    post :bulk_create
    patch :bulk_update
    delete :bulk_delete
  end
end
```

Implementation:

```ruby
def bulk_create
  posts = params[:posts].map do |attrs|
    Post.create(attrs)
  end
  respond_with posts, status: :created
end

def bulk_update
  Post.where(id: params[:ids]).update_all(params[:updates])
  respond_with Post.where(id: params[:ids])
end

def bulk_delete
  Post.where(id: params[:ids]).destroy_all
  head :no_content
end
```

### Derived data

```ruby
resources :posts do
  member do
    get :preview    # Rendered preview
    get :stats      # View counts, likes, etc.
    get :history    # Version history
  end
end
```

These don't modify the resource, just return derived data:

```ruby
def preview
  post = Post.find(params[:id])
  preview_html = MarkdownRenderer.render(post.body)
  render json: { ok: true, preview: preview_html }
end

def stats
  post = Post.find(params[:id])
  render json: {
    ok: true,
    stats: {
      views: post.view_count,
      likes: post.likes_count,
      comments: post.comments_count
    }
  }
end
```

### Search actions

```ruby
resources :posts do
  collection do
    get :search
  end
end
```

But consider: Do you need this, or can you use filters?

```ruby
# Custom search action
# GET /api/v1/posts/search?q=rails

# vs. using filters
# GET /api/v1/posts?filter[title][contains]=rails
```

Filters are built-in and work with all `filterable` attributes. Use a custom `search` action when:
- You need full-text search (Elasticsearch, pg_search)
- You search across multiple tables
- You need custom relevance scoring

## Actions vs filters vs separate resources

Sometimes it's not clear whether to use an action, a filter, or a separate resource.

### Use filters when:
You're just narrowing down the collection:

```ruby
# Good: Use filters
GET /api/v1/posts?filter[published]=true
GET /api/v1/posts?filter[created_at][greater_than]=2024-01-01

# Not needed: Custom action
collection do
  get :published
  get :recent
end
```

### Use actions when:
The operation is complex or changes state:

```ruby
# Good: Custom action for complex operation
member do
  post :duplicate  # Creates a copy with related records
end

# Good: State transition
member do
  patch :publish
end

# Bad: Could be a filter
collection do
  get :published  # Just filter[published]=true
end
```

### Use separate resources when:
The action represents a different resource type:

```ruby
# Bad: Action for searching
collection do
  get :search
end

# Good: Separate search resource
resource :search, only: :show
# GET /api/v1/search?q=rails

# Or even better: use filters
# GET /api/v1/posts?filter[title][contains]=rails
```

## Path helpers and route names

Actions get named routes like standard actions:

```ruby
resources :posts do
  member do
    patch :publish
  end

  collection do
    get :drafts
  end
end
```

Named routes (if you need them in Rails):
- `publish_api_v1_post_path(post)` → `/api/v1/posts/:id/publish`
- `drafts_api_v1_posts_path` → `/api/v1/posts/drafts`

But in an API, you usually just hardcode URLs or generate them from OpenAPI schema.

## Actions with parameters

Actions can accept additional parameters:

```ruby
member do
  post :duplicate
end
```

Contract:

```ruby
action :duplicate do
  input do
    param :new_title, type: :string, required: false
    param :copy_comments, type: :boolean, default: false
  end

  output do
    param :id, type: :integer, required: true
    param :title, type: :string, required: true
  end
end
```

Controller:

```ruby
def duplicate
  original = Post.find(params[:id])

  new_post = original.dup
  new_post.title = params[:new_title] if params[:new_title]
  new_post.save!

  if params[:copy_comments]
    original.comments.each do |comment|
      new_post.comments.create(comment.attributes.except('id', 'post_id'))
    end
  end

  respond_with new_post, status: :created
end
```

## When NOT to use custom actions

Before adding a custom action, consider:

**Don't use actions for simple filters:**
```ruby
# Bad
collection do
  get :published
end

# Good
# GET /api/v1/posts?filter[published]=true
```

**Don't use actions for separate resources:**
```ruby
# Bad
resources :posts do
  collection do
    get :search
  end
end

# Good
resource :search, only: :show
```

**Don't use actions when you should use standard CRUD:**
```ruby
# Bad
resources :posts do
  member do
    patch :change_title
  end
end

# Good - just use update
# PATCH /api/v1/posts/:id
# { "post": { "title": "New title" } }
```

## Next steps

- **[Configuration](./configuration.md)** - Schema endpoints and documentation
- **[Routing Options](./routing-options.md)** - All available options
- **[Advanced](./advanced.md)** - with_options and concerns
- **[Contracts: Actions](../contracts/actions.md)** - Defining action contracts
