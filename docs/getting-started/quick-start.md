# Quick Start

Let's build a blog API in 5 minutes.

No, really. Five minutes. We're going to create a full CRUD API with filtering, sorting, pagination, validation, and TypeScript types.

Ready?

## What you need

- A Rails app with Apiwork installed ([Installation guide](./installation.md))
- A `Post` model (we'll create one now)

## Step 1: Create the model

If you don't have a Post model yet:

```bash
rails generate model Post title:string body:text published:boolean
rails db:migrate
```

## Step 2: Mount Apiwork routes

Add this to `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Apiwork.routes => '/'
end
```

This mounts all your API definitions from `config/apis/`.

## Step 3: Define your API

Create `config/apis/v1.rb`:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end
```

One line. That's your entire routing file.

The path `/api/v1` does two things:
1. **Sets the URL** - Routes are accessible under `/api/v1`
2. **Sets the namespace** - Expects `Api::V1::` controllers, contracts, and schemas

You can also use the root path:

```ruby
Apiwork::API.draw '/' do
  resources :posts
end
# Routes at /posts, expects Root:: namespace
```

This gives you all the standard REST routes - index, show, create, update, destroy. Just like Rails `resources :posts`, but with automatic namespace resolution.

## Step 4: Describe your data

Create `app/schemas/api/v1/post_schema.rb`:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
  attribute :published, filterable: true, writable: true
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
end
```

See what we're doing? We're just describing what each field can do:
- `filterable` - Users can filter by this field
- `sortable` - Users can sort by this field
- `writable` - Users can set this field when creating/updating

No implementation. Just description.

## Step 5: Create the contract

Create `app/contracts/api/v1/post_contract.rb`:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema
end
```

That's it! Just **one line** after the class definition.

When you link a schema with `schema PostSchema`, Apiwork **automatically generates** all CRUD actions (index, show, create, update, destroy) with:
- Input validation based on `writable` attributes
- Output structure with all attributes
- Filter/sort/pagination for index
- Proper required field detection from database

You only need to explicitly define actions if you want to **override** the defaults or add **custom actions**.

## Step 6: Create the controller

Create `app/controllers/api/v1/posts_controller.rb`:

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
    post = Post.create(action_params)
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

## Step 7: Test your API

Start your Rails server:

```bash
rails server
```

### List posts

```bash
curl http://localhost:3000/api/v1/posts
```

Response:

```json
{
  "ok": true,
  "posts": [],
  "meta": {
    "page": {
      "current": 1,
      "next": null,
      "prev": null,
      "total": 0,
      "items": 0
    }
  }
}
```

### Create a post

```bash
curl -X POST http://localhost:3000/api/v1/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "My First Post", "body": "Hello, Apiwork!", "published": true}}'
```

Response:

```json
{
  "ok": true,
  "post": {
    "id": 1,
    "title": "My First Post",
    "body": "Hello, Apiwork!",
    "published": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

Notice the automatic `camelCase` transformation!

### Filter posts

```bash
curl "http://localhost:3000/api/v1/posts?filter[published]=true"
```

### Sort posts

```bash
curl "http://localhost:3000/api/v1/posts?sort[created_at]=desc"
```

### Paginate posts

```bash
curl "http://localhost:3000/api/v1/posts?page[number]=1&page[size]=10"
```

### Combine queries

```bash
curl "http://localhost:3000/api/v1/posts?filter[published]=true&sort[created_at]=desc&page[size]=5"
```

## What did `schema PostSchema` give you?

That single line automatically generated **5 complete actions**:

### 1. INDEX - List with querying
```ruby
# Auto-generated input contract:
{
  filter: {
    id: integer | { equal, not_equal, greater_than, less_than, in, ... },
    title: string | { equal, contains, starts_with, in, ... },
    published: boolean | { equal }
  },
  sort: { id: 'asc'|'desc', title: 'asc'|'desc' } | [multiple sorts],
  page: { number: integer, size: integer }
}

# Auto-generated output contract:
{
  ok: true,
  posts: [{ id, title, body, published, created_at, updated_at }],
  meta: { page: { current, next, prev, total, items } }
}
```

### 2. SHOW - Get single resource
```ruby
# Input: none (strict mode, rejects query params)
# Output: { ok: true, post: { id, title, body, published, ... } }
```

### 3. CREATE - Create new resource
```ruby
# Auto-generated input (based on writable: true):
{
  post: {  # Root key required
    title: string (required),    # DB column: null: false → required: true
    body: string (required),     # DB column: null: false → required: true
    published: boolean           # DB column: default: false → optional
  }
}

# Output: { ok: true, post: { id, title, ... } }
```

Notice how the `required` flags come from your database schema? Apiwork reads your database column definitions (`null: false`) and automatically makes those fields required in the API. Change your migration, Apiwork adapts.

### 4. UPDATE - Update resource
```ruby
# Auto-generated input (all writable fields become optional):
{
  post: {
    title: string?,
    body: string?,
    published: boolean?
  }
}

# Output: { ok: true, post: { id, title, ... } }
```

### 5. DESTROY - Delete resource
```ruby
# Input: none
# Output: { ok: true }
```

## What just happened?

With **~50 lines of code** (and most of it just defining attributes), you created:

1. ✅ **Full REST API** with 5 endpoints
2. ✅ **Input validation** - Type checking, required fields, auto-detected from DB
3. ✅ **Output serialization** - Consistent JSON responses with camelCase
4. ✅ **Filtering** - All operators based on attribute type (contains, greater_than, in, etc.)
5. ✅ **Sorting** - Multiple fields, asc/desc
6. ✅ **Pagination** - With meta information (current, next, prev, total, items)
7. ✅ **Type safety** - Validated inputs and outputs
8. ✅ **Documentation** - Auto-generated OpenAPI schema

## View the OpenAPI schema

```bash
curl http://localhost:3000/api/v1/.schema/openapi
```

This returns a complete OpenAPI 3.1 specification of your API!

## Generate TypeScript types

```bash
curl http://localhost:3000/api/v1/.schema/transport
```

Use this in your frontend to get type-safe API calls.

## Next steps

Now that you have a working API:

1. **Add more fields** to your schema
2. **Add custom actions** like `publish` or `archive`
3. **Add associations** like comments on posts
4. **Customize validation** in your contract
5. **Add authentication** to your controllers

### Learn more:

- [Core Concepts](./core-concepts.md) - Understand how everything works
- [API Definition](../api-definition/introduction.md) - Advanced routing
- [Schemas](../schemas/introduction.md) - Deep dive into schemas
- [Contracts](../contracts/introduction.md) - Advanced validation
- [Querying](../querying/introduction.md) - All query capabilities

## Overriding auto-generated actions

Want to customize validation? Just define the action explicitly:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema

  # Override the auto-generated create action
  action :create do
    input do
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, default: false

      # Add custom validation not in schema
      param :tags, type: :array, of: :string, required: false
    end

    # Output still auto-generated from schema unless you override it too
  end

  # Other actions (show, index, update, destroy) still auto-generated
end
```

**When to override:**
- Add custom input fields not in schema
- Change validation rules (stricter/looser than schema)
- Add custom business logic validation
- Different input shape than schema attributes

**When NOT to override:**
- Standard CRUD with schema attributes → Auto-generation handles it perfectly!

## Common next steps

### Add a custom action

In `config/apis/v1.rb`:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts do
    member do
      patch :publish
    end
  end
end
```

In your contract:

```ruby
action :publish do
  output do
    param :id, type: :integer, required: true
    param :published, type: :boolean, required: true
    param :published_at, type: :datetime, required: true
  end
end
```

In your controller:

```ruby
def publish
  post = Post.find(params[:id])
  post.update(published: true, published_at: Time.current)
  respond_with post
end
```

### Add nested associations (Rails native!)

Create a Comment model:

```bash
rails generate model Comment post:references body:text author:string
rails db:migrate
```

Enable nested attributes in your model (standard Rails):

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

Update your schemas:

```ruby
# app/schemas/api/v1/comment_schema.rb
class Api::V1::CommentSchema < Apiwork::Schema::Base
  model Comment

  attribute :id
  attribute :body, writable: true
  attribute :author, writable: true
  attribute :created_at
end

# app/schemas/api/v1/post_schema.rb
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title, writable: true
  attribute :body, writable: true

  # Make the association writable
  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true,        # Accept nested attributes
    allow_destroy: true    # Auto-detected from model
end
```

Now you can create posts with comments in one request:

```bash
curl -X POST http://localhost:3000/api/v1/posts \
  -H "Content-Type: application/json" \
  -d '{
    "post": {
      "title": "My Post",
      "body": "Content",
      "comments": [
        { "body": "First comment", "author": "Alice" },
        { "body": "Second comment", "author": "Bob" }
      ]
    }
  }'
```

Update with nested attributes:

```bash
curl -X PATCH http://localhost:3000/api/v1/posts/1 \
  -H "Content-Type: application/json" \
  -d '{
    "post": {
      "comments": [
        { "id": 5, "body": "Updated comment" },
        { "id": 6, "_destroy": true },
        { "body": "New comment" }
      ]
    }
  }'
```

This is **pure Rails** `accepts_nested_attributes_for`. Apiwork transforms `comments` → `comments_attributes` internally and validates the structure. You just use the association name in your API.

You can also query by associations:

```bash
# Include comments in response
curl "http://localhost:3000/api/v1/posts?include[comments]=true"

# Filter posts by comment content
curl "http://localhost:3000/api/v1/posts?filter[comments][body][contains]=important"
```

### Add authentication

In your controller:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  before_action :authenticate_user!

  def create
    post = current_user.posts.create(action_params)
    respond_with post, status: :created
  end
end
```

Apiwork works seamlessly with Devise, JWT, or any authentication system!
