# action_params

The `action_params` method extracts validated parameters for create and update actions. It unwraps root keys and transforms nested associations to Rails' `_attributes` format.

## Basic usage

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

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
end
```

## What it does

`action_params` handles three transformations:

1. **Unwraps root key** - `{ post: { title: "..." } }` → `{ title: "..." }`
2. **Validates params** - Already done by contract before action runs
3. **Transforms nested associations** - `{ comments: [...] }` → `{ comments_attributes: [...] }`

## Simple params

For models without nested associations:

Request:
```json
{
  "post": {
    "title": "My Post",
    "body": "Content here",
    "published": true
  }
}
```

Controller:
```ruby
def create
  post = Post.new(action_params)
  post.save
  respond_with post, status: :created
end
```

`action_params` returns:
```ruby
{
  title: "My Post",
  body: "Content here",
  published: true
}
```

The root key (`post`) is unwrapped automatically.

## Nested associations

For models with `accepts_nested_attributes_for`:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments
end
```

Schema:
```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title, writable: true
  attribute :body, writable: true

  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true  # Enables nested writes
end
```

Request:
```json
{
  "post": {
    "title": "My Post",
    "body": "Content here",
    "comments": [
      { "body": "First comment" },
      { "body": "Second comment" }
    ]
  }
}
```

`action_params` transforms to:
```ruby
{
  title: "My Post",
  body: "Content here",
  comments_attributes: [
    { body: "First comment" },
    { body: "Second comment" }
  ]
}
```

The `comments` key becomes `comments_attributes`, which Rails expects for nested attributes.

## Only for create and update

`action_params` only works in create and update actions:

```ruby
def create
  post = Post.new(action_params)  # ✅ Works
  post.save
  respond_with post, status: :created
end

def index
  posts = query(Post.all)  # ✅ Use query() instead
  respond_with posts
end

def custom_action
  # For custom actions, access validated_request.params directly
  title = validated_request.params[:title]  # ✅ Works
end
```

For other actions, use `validated_request.params` to access validated parameters.

## Deeply nested associations

Nested associations can be nested further:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments
end

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author
  accepts_nested_attributes_for :author
end
```

Request:
```json
{
  "post": {
    "title": "My Post",
    "comments": [
      {
        "body": "Great post!",
        "author": {
          "name": "Alice"
        }
      }
    ]
  }
}
```

`action_params` transforms to:
```ruby
{
  title: "My Post",
  comments_attributes: [
    {
      body: "Great post!",
      author_attributes: {
        name: "Alice"
      }
    }
  ]
}
```

All nested associations are transformed recursively.

## Validation before action_params

Parameters are validated **before** your action runs:

```ruby
def create
  # At this point, params are already validated by contract
  post = Post.new(action_params)  # Safe to use
  post.save
  respond_with post, status: :created
end
```

If validation fails, the action never runs. A 422 error is returned automatically.

## Root key configuration

Root keys are determined by your schema:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post  # Root key: "post"
end
```

Request must have matching root key:
```json
{
  "post": {
    "title": "..."
  }
}
```

To disable root keys globally:

```ruby
# config/initializers/apiwork.rb
Apiwork.configure do |config|
  config.require_root_key = false
end
```

Now requests can be flat:
```json
{
  "title": "...",
  "body": "..."
}
```

And `action_params` returns params as-is (no unwrapping needed).

## Accessing other params

`action_params` only returns writable params for create/update. For other parameters:

```ruby
def custom_action
  # Access all validated params
  all_params = validated_request.params

  # Access specific params
  filter_params = validated_request.params[:filter]
  sort_params = validated_request.params[:sort]
end
```

`validated_request` is available in all actions and provides access to the full validated parameter hash.

## Transformation details

Here's exactly what `action_params` does:

**1. For create/update actions:**
```ruby
# Input (from request)
{
  post: {
    title: "My Post",
    comments: [{ body: "Comment" }]
  }
}

# After action_params
{
  title: "My Post",
  comments_attributes: [{ body: "Comment" }]
}
```

**2. For other actions:**
Returns all validated params without unwrapping or transformation.

**3. Transform rules:**
- Unwrap root key (e.g., `post`)
- Find writable associations in schema
- Transform association keys to `_attributes` format
- Recursively transform nested associations
- Leave non-association params unchanged

## Working with accepts_nested_attributes_for

For nested writes to work, your model must use `accepts_nested_attributes_for`:

```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

And your schema must mark the association as writable:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true,           # Enables nested writes
    allow_destroy: true       # Allows _destroy flag
end
```

**Important:** Apiwork validates that `accepts_nested_attributes_for` is configured when you mark an association as `writable: true`. If it's missing, schema initialization will raise an error.

## Example: Complete nested write

Model:
```ruby
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end
```

Schema:
```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :title, writable: true
  attribute :body, writable: true

  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true,
    allow_destroy: true
end

class Api::V1::CommentSchema < Apiwork::Schema::Base
  model Comment

  attribute :body, writable: true
end
```

Contract (auto-generated from schema):
```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema
end
```

Controller:
```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

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
end
```

Request:
```json
{
  "post": {
    "title": "My Post",
    "body": "Content here",
    "comments": [
      { "body": "First comment" },
      { "body": "Second comment", "_destroy": true }
    ]
  }
}
```

Everything just works. `action_params` handles the transformation, Rails handles the nested creation/destruction.

## What action_params does NOT do

These features are **not supported**:

- ❌ Strong parameters filtering - Contracts handle validation, not strong params
- ❌ Custom transformation blocks - Transformation is automatic based on schema
- ❌ Permit/require - Not needed, contracts define structure
- ❌ Per-action param customization - Use `validated_request.params` for custom logic

Apiwork replaces Rails' strong parameters with contract-based validation.

## Next steps

- **[respond_with](./respond_with.md)** - Building responses
- **[query](./query.md)** - Filtering, sorting, and pagination
- **[Introduction](./introduction.md)** - Back to controllers overview
