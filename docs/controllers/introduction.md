# Controllers

Controllers are where your API logic lives. They handle requests, process data, and send responses.

Apiwork provides a simple concern that adds validation, querying, serialization, and response building to your Rails controllers.

## The basics

Include `Apiwork::Controller::Concern` in your controller:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    posts = query(Post.all)
    respond_with posts
  end

  def show
    post = Post.find(params[:id])
    respond_with post
  end

  def create
    post = Post.new(action_params)
    post.save
    respond_with post, status: :created
  end

  def update
    post = Post.find(params[:id])
    post.update(action_params)
    respond_with post
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    respond_with post
  end
end
```

That's it. Three helper methods handle everything:
- `query(scope)` - Applies filters, sorting, pagination
- `action_params` - Gets validated params for create/update
- `respond_with(resource)` - Serializes and sends response

## What the concern provides

When you include `Apiwork::Controller::Concern`, you get:

1. **Automatic request validation** - Input params are validated against your contract before the action runs
2. **Automatic response validation** - Output is validated against your contract (in development/test)
3. **Query helper** - `query(scope)` applies filter/sort/pagination from params
4. **Action params helper** - `action_params` extracts and transforms validated params
5. **Response helper** - `respond_with(resource)` builds proper JSON responses
6. **Disabled parameter wrapping** - Contracts handle parameter structure explicitly

## Request lifecycle

Here's what happens on each request:

```
1. Request comes in → GET /api/v1/posts?filter[published]=true&sort[created_at]=desc

2. Apiwork finds your contract → Api::V1::PostContract

3. Input validation runs → Validates filter, sort, page params against contract

4. Your action runs → def index; posts = query(Post.all); respond_with posts; end

5. Query applies params → Filters by published=true, sorts by created_at desc

6. Response serialized → Schema serializes posts to JSON

7. Output validation runs → Validates response structure against contract

8. Response sent → { ok: true, posts: [...], meta: {...} }
```

Everything between steps 2-3 and 6-7 is automatic. You just write step 4.

## Controller structure

Your controllers are simple:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  # Standard CRUD
  def index
    respond_with query(Post.all)
  end

  def show
    respond_with Post.find(params[:id])
  end

  def create
    post = Post.new(action_params)
    post.save
    respond_with post, status: :created
  end

  def update
    post = Post.find(params[:id])
    post.update(action_params)
    respond_with post
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    respond_with post
  end
end
```

No manual validation. No manual serialization. No manual response building.

## Custom actions

Beyond CRUD:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  # Member action
  def publish
    post = Post.find(params[:id])
    post.update(published: true, published_at: Time.current)
    respond_with post
  end

  # Collection action
  def drafts
    posts = query(Post.where(published: false))
    respond_with posts
  end

  # Custom action with params
  def bulk_create
    posts = action_params[:posts].map { |attrs| Post.create(attrs) }
    respond_with posts, status: :created
  end
end
```

Define contracts for these actions:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema  # Standard CRUD

  action :publish do
    output do
      param :id, type: :integer, required: true
      param :published, type: :boolean, required: true
      param :published_at, type: :datetime, required: true
    end
  end

  action :drafts do
    # Uses schema-generated index contract
  end

  action :bulk_create do
    input do
      param :posts, type: :array, required: true, of: :object do
        param :title, type: :string, required: true
        param :body, type: :string, required: true
      end
    end
  end
end
```

## Error handling

Apiwork handles validation errors automatically:

```ruby
def create
  post = Post.new(action_params)
  post.save
  respond_with post, status: :created
end
```

If `post.save` fails (Active Record validations):

```json
{
  "ok": false,
  "errors": [
    {
      "code": "invalid",
      "path": "/post/title",
      "message": "can't be blank"
    }
  ]
}
```

Status: 422 Unprocessable Content

Active Record errors are automatically converted to Apiwork's error format.

## Response format

All responses have the same structure:

**Success response:**
```json
{
  "ok": true,
  "post": { "id": 1, "title": "...", ... }
}
```

**Collection response:**
```json
{
  "ok": true,
  "posts": [{ "id": 1, ... }, { "id": 2, ... }],
  "meta": {
    "page": {
      "current": 1,
      "next": 2,
      "prev": null,
      "total": 10,
      "items": 100
    }
  }
}
```

**Error response:**
```json
{
  "ok": false,
  "errors": [
    { "code": "...", "path": "...", "message": "..." }
  ]
}
```

**Delete response:**
```json
{
  "ok": true,
  "meta": {}
}
```

The `ok` field is always present. It's `true` for success, `false` for errors.

## Before filters and authorization

Use standard Rails before_action:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  before_action :authenticate_user!
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :authorize_post, only: [:update, :destroy]

  def show
    respond_with @post
  end

  def update
    @post.update(action_params)
    respond_with @post
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post
    head :forbidden unless @post.user_id == current_user.id
  end
end
```

Apiwork doesn't interfere with Rails conventions.

## Namespacing

Controllers follow Rails conventions:

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      include Apiwork::Controller::Concern

      # Apiwork automatically finds:
      # - Contract: Api::V1::PostContract
      # - Schema: Api::V1::PostSchema
    end
  end
end
```

The namespace matches your API definition path:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts
end
```

Path `/api/v1` → Namespace `Api::V1` → Controllers, contracts, schemas all in `Api::V1`.

## Next steps

- **[respond_with](./respond_with.md)** - Building responses with respond_with
- **[action_params](./action_params.md)** - Accessing validated parameters
- **[query](./query.md)** - Filtering, sorting, and pagination
