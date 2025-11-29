# Core Concepts

Apiwork isn't a replacement for Rails - it's Rails with superpowers for building APIs.

Everything you know about Rails still applies. Models are ActiveRecord. Controllers are ActionController. Routes are Rails routes. The only difference is that we add explicit declarations about what your API does, and generate everything else from that.

## The four layers

Apiwork has four main components that work together:

```
┌─────────────────────────────────────────┐
│  1. API Definition (Routes)             │
│  Apiwork::API.draw                      │
│  Define: resources, actions, nesting    │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│  2. Controller (Orchestration)          │
│  include Apiwork::Controller::Concern   │
│  Uses: query(), respond_with()          │
└─────────────────────────────────────────┘
                   ↓
┌──────────────────────┬──────────────────┐
│  3. Contract         │  4. Schema       │
│  (Validation)        │  (Serialization) │
│  Input/Output types  │  Attributes      │
└──────────────────────┴──────────────────┘
```

Let's understand each layer.

## 1. API Definition

**Purpose**: Define what endpoints exist and how they're structured.

**Example**:

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts do
    resources :comments

    member do
      patch :publish
    end
  end
end
```

**What it does**:
- Creates routes (URLs + HTTP methods)
- Determines namespace (`Api::V1`)
- Defines resource hierarchy
- Maps routes to controller actions

**Key concept**: The path `/api/v1` determines both the mount point and the namespace. All controllers, schemas, and contracts live under `Api::V1`.

## 2. Controller

**Purpose**: Orchestrate request handling - validate input, fetch data, serialize output.

**Example**:

```ruby
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    posts = query(Post.all)
    respond_with posts
  end

  def create
    post = Post.create(action_params)
    respond_with post, status: :created
  end
end
```

**What it does**:
- Validates input (before_action)
- Provides `action_params` (validated, transformed params)
- Provides `query()` (applies filter, sort, pagination)
- Provides `respond_with()` (serializes and wraps response)

**Key concept**: Controllers are thin. They don't handle validation logic or serialization - that's delegated to contracts and schemas.

## 3. Contract

**Purpose**: Define and validate what goes in and what comes out of each action.

**Example**:

```ruby
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema

  action :create do
    input do
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, default: false
    end

    output do
      param :id, type: :integer, required: true
      param :title, type: :string, required: true
      param :body, type: :string, required: true
      param :published, type: :boolean, required: true
      param :created_at, type: :datetime, required: true
    end
  end
end
```

**What it does**:
- Validates input types (string, integer, boolean, etc.)
- Checks required fields
- Applies defaults
- Validates output structure
- Generates OpenAPI/TypeScript/Zod schemas

**Key concept**: Contracts are the "shape" of your API. They define the contract between client and server.

## 4. Schema

**Purpose**: Declare what your data model can do in the API context.

**Example**:

```ruby
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post  # Links to your ActiveRecord model

  # Types are inferred from database columns
  attribute :id, filterable: true, sortable: true
  attribute :title, filterable: true, sortable: true, writable: true
  attribute :body, writable: true
  attribute :published, filterable: true, writable: true
  attribute :created_at, sortable: true

  # Associations use Rails' accepts_nested_attributes_for
  has_many :comments,
    schema: Api::V1::CommentSchema,
    writable: true  # Enables nested attributes
end
```

**What it does**:
- Links to your ActiveRecord model
- Declares which attributes are filterable, sortable, writable
- Infers types from database columns (string, integer, boolean, datetime, etc.)
- Infers required fields from `null: false` constraints
- Handles associations using Rails' nested attributes
- Serializes objects to JSON

**Key concept**: Schemas extend your ActiveRecord models with API capabilities. They don't replace your models - they describe what your models can do in an API context.

## How they work together

Let's trace a request through all four layers:

### Creating a post: `POST /api/v1/posts`

**Request**:

```json
{
  "post": {
    "title": "New Post",
    "body": "Content here"
  }
}
```

**1. API Definition matches route**:

```ruby
# Route: POST /api/v1/posts → Api::V1::PostsController#create
resources :posts
```

**2. Controller receives request**:

```ruby
def create
  # Before action: Contract validates input
  #   - Checks title is string ✓
  #   - Checks body is string ✓
  #   - Applies published: false (default)

  # action_params returns validated data:
  # { title: "New Post", body: "Content here", published: false }
  post = Post.create(action_params)

  # respond_with serializes using schema:
  #   - Includes attributes defined in PostSchema
  #   - Transforms keys (snake_case → camelCase)
  #   - Wraps in root key: { post: {...} }
  #   - Validates against output contract
  respond_with post, status: :created
end
```

**3. Contract validates**:

```ruby
# Input validation (before action)
action :create do
  input do
    param :title, type: :string, required: true      # ✓ Present, is string
    param :body, type: :string, required: true       # ✓ Present, is string
    param :published, type: :boolean, default: false # Applied default
  end
end

# Output validation (after serialization)
# Ensures response matches expected structure
```

**4. Schema serializes**:

```ruby
# PostSchema defines which attributes to include:
attribute :id       # Include in response
attribute :title    # Include in response
attribute :body     # Include in response
attribute :published # Include in response
attribute :created_at # Include in response

# Result: { id: 1, title: "New Post", body: "Content here", published: false, created_at: "..." }
```

**Response**:

```json
{
  "ok": true,
  "post": {
    "id": 1,
    "title": "New Post",
    "body": "Content here",
    "published": false,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### Querying posts: `GET /api/v1/posts?filter[published]=true&sort[created_at]=desc`

**1. API Definition matches route**:

```ruby
# Route: GET /api/v1/posts → Api::V1::PostsController#index
resources :posts
```

**2. Controller receives request**:

```ruby
def index
  # query() helper:
  #   - Reads filter[published]=true from params
  #   - Checks if 'published' is filterable in PostSchema ✓
  #   - Applies: Post.all.where(published: true)
  #
  #   - Reads sort[created_at]=desc from params
  #   - Checks if 'created_at' is sortable in PostSchema ✓
  #   - Applies: .order(created_at: :desc)
  #
  #   - Applies pagination: .limit(20).offset(0)

  posts = query(Post.all)
  # Posts are still ActiveRecord::Relation at this point

  # respond_with:
  #   - Executes query
  #   - Serializes each post using PostSchema
  #   - Wraps in root key: { posts: [...] }
  #   - Adds pagination meta
  respond_with posts
end
```

**3. Schema controls filtering and serialization**:

```ruby
# Schema defines which attributes are filterable/sortable:
attribute :published, filterable: true  # ✓ Allows filter[published]=...
attribute :created_at, sortable: true   # ✓ Allows sort[created_at]=...

# If we tried filter[body]=..., it would be rejected (not filterable)
# If we tried sort[body]=..., it would be rejected (not sortable)
```

**Response**:

```json
{
  "ok": true,
  "posts": [
    {
      "id": 5,
      "title": "Latest Post",
      "published": true,
      "createdAt": "2024-01-15T10:00:00Z"
    },
    {
      "id": 3,
      "title": "Another Post",
      "published": true,
      "createdAt": "2024-01-14T15:30:00Z"
    }
  ],
  "meta": {
    "page": {
      "current": 1,
      "next": null,
      "prev": null,
      "total": 1,
      "items": 2
    }
  }
}
```

## Convention over configuration

Apiwork uses conventions to connect these layers automatically.

### File structure convention

```
config/apis/v1.rb                         → Defines routes under /api/v1
app/controllers/api/v1/posts_controller.rb → Api::V1::PostsController
app/schemas/api/v1/post_schema.rb         → Api::V1::PostSchema
app/contracts/api/v1/post_contract.rb     → Api::V1::PostContract
```

### Auto-resolution

When you define:

```ruby
resources :posts
```

Apiwork automatically looks for:
1. `Api::V1::PostsController`
2. `Api::V1::PostContract`
3. `Api::V1::PostSchema`

No configuration needed!

### Overriding conventions

When you need something different:

```ruby
resources :posts,
  controller: 'admin/posts',        # Use Api::V1::Admin::PostsController
  contract: '/custom/post'          # Use Custom::PostContract (absolute path)
```

## Schema vs Contract

Understanding the difference is crucial:

### Schema = Primary Building Block (Required)

- Defines your data model
- Based on ActiveRecord models
- Controls serialization
- Defines query capabilities (filterable, sortable)
- Defines writability (which fields accept input)
- **Auto-generates contracts for CRUD operations**

**Think**: Schema is about the **resource** itself and what it can do.

**In 90% of cases, you only need a schema.**

### Contract = Optional Customization (Only When Needed)

- Defines custom API operations beyond CRUD
- Validates input and output for each action
- Can override auto-generated behavior
- Generates API documentation

**Think**: Contract is for **custom interactions** beyond standard CRUD.

**Only create a contract when you need:**
- Custom actions (search, publish, etc.)
- Override default validation behavior
- Complex nested input transformations

### Example showing the difference:

```ruby
# Schema: The Post resource (This is all you need!)
class Api::V1::PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id, filterable: true, sortable: true
  attribute :title, writable: true, filterable: true, sortable: true
  attribute :body, writable: true
  attribute :published, writable: true
  attribute :author_id
  attribute :created_at, sortable: true
  attribute :updated_at, sortable: true
end

# Contract: OPTIONAL - only needed for custom behavior
# If you don't create this file, Apiwork auto-generates it from the schema!
class Api::V1::PostContract < Apiwork::Contract::Base
  schema Api::V1::PostSchema

  # Without explicit actions, all CRUD actions are auto-generated:
  # - index with filter/sort/pagination
  # - show
  # - create (writable attributes as input)
  # - update (writable attributes as input, all optional)
  # - destroy

  # Only add custom actions when you need them:
  action :publish do
    input { param :scheduled_at, type: :datetime }
  end
end
```

**Note:** You must create a contract class for each schema. The contract defines the actions available for that resource. For basic CRUD operations, a minimal contract with just `schema YourSchema` is sufficient. Add custom actions when you need additional endpoints beyond the standard CRUD operations.

See [Schema-First Design](../schemas/schema-first-design.md) for more details.

**Auto-generated CREATE action** looks like:
```ruby
action :create do
  input do
    param :post, type: :object, required: true do
      # Only writable attributes included
      param :title, type: :string, required: true    # required from DB
      param :body, type: :string, required: true     # required from DB
      param :published, type: :boolean               # optional (has DB default)
    end
  end

  output do
    param :ok, type: :boolean, required: true
    param :post, type: :object, required: true do
      # ALL attributes included in output
      param :id, type: :integer
      param :title, type: :string
      param :body, type: :string
      param :published, type: :boolean
      param :author_id, type: :integer
      param :created_at, type: :datetime
      param :updated_at, type: :datetime
    end
  end
end
```

**Auto-generated INDEX action** includes:
```ruby
action :index do
  input do
    param :filter, type: :object do
      # Filterable attributes get filter operators
      param :id, type: :union do
        variant type: :integer  # Shorthand: filter[id]=123
        variant type: :object do
          param :equal, type: :integer
          param :not_equal, type: :integer
          param :greater_than, type: :integer
          param :less_than, type: :integer
          param :in, type: :array, of: :integer
          # ... more operators
        end
      end

      param :title, type: :union do
        variant type: :string  # Shorthand: filter[title]=exact
        variant type: :object do
          param :equal, type: :string
          param :contains, type: :string
          param :starts_with, type: :string
          param :in, type: :array, of: :string
          # ... more operators
        end
      end

      param :published, type: :union do
        variant type: :boolean  # Shorthand: filter[published]=true
        variant type: :object do
          param :equal, type: :boolean
        end
      end
    end

    param :sort, type: :union do
      variant type: :object do
        # Sortable attributes
        param :id, type: :string, enum: ['asc', 'desc']
        param :title, type: :string, enum: ['asc', 'desc']
        param :created_at, type: :string, enum: ['asc', 'desc']
      end
      variant type: :array, of: :object  # Multiple sorts
    end

    param :page, type: :object do
      param :number, type: :integer
      param :size, type: :integer
    end
  end

  output do
    param :ok, type: :boolean, required: true
    param :posts, type: :array, required: true do
      # Each item has all attributes
    end
    param :meta, type: :object, required: true do
      param :page, type: :object do
        param :current, type: :integer, required: true
        param :next, type: :integer
        param :prev, type: :integer
        param :total, type: :integer, required: true
        param :items, type: :integer, required: true
      end
    end
  end
end
```

Notice:
- **Schema** defines what Post IS and what it CAN DO (filterable, sortable, writable)
- **Contract** with `schema PostSchema` AUTO-GENERATES all actions based on schema capabilities
- You only define actions explicitly when you need to OVERRIDE defaults

## Data transformation flow

Understanding how data is transformed:

```
Client sends:                          Controller receives:
{                                      {
  "post": {                              "post": {
    "title": "Hello"        →              "title": "Hello"
  }                                        }
}                                      }
        ↓ input_key_format           ↓ Contract validation
Rails params:                          Validated params:
{                                      {
  "post" => {                            title: "Hello",
    "title" => "Hello"     →             published: false  # default applied
  }                                    }
}
        ↓ action_params extracts              ↓ ActiveRecord save
Create Post:                           Post object:
Post.create(                           #<Post
  title: "Hello",          →             id: 1,
  published: false                       title: "Hello",
)                                        published: false,
                                         created_at: ...,
                                         updated_at: ...
                                       >
        ↓ Schema serialization                ↓ output_key_format
Serialized hash:                       Final JSON:
{                                      {
  id: 1,                   →             "ok": true,
  title: "Hello",                        "post": {
  published: false,                        "id": 1,
  created_at: ...                          "title": "Hello",
}                                          "published": false,
                                           "createdAt": "..."
                                         }
                                       }
```

## Database type inference

Apiwork reads your database schema to understand your data:

```ruby
# Your migration:
create_table :posts do |t|
  t.string :title, null: false        # String, required
  t.text :body, null: false           # Text (string), required
  t.boolean :published, default: false # Boolean, optional (has default)
  t.integer :view_count, default: 0   # Integer, optional (has default)
  t.datetime :published_at            # Datetime, optional (null: true)
  t.timestamps                        # Datetime, optional
end

# Apiwork automatically infers:
attribute :title
  # → type: string
  # → required: true (when writable)

attribute :body
  # → type: string
  # → required: true (when writable)

attribute :published
  # → type: boolean
  # → required: false (has default)

attribute :view_count
  # → type: integer
  # → required: false (has default)

attribute :published_at
  # → type: datetime
  # → required: false (nullable)
```

**Benefits:**
- Change your migration, API updates automatically
- No duplication of type information
- Required fields come from database constraints
- Single source of truth (the database)

**Supported types:**
- `string`, `text` → `:string`
- `integer`, `bigint` → `:integer`
- `boolean` → `:boolean`
- `decimal`, `float` → `:decimal`, `:float`
- `datetime`, `timestamp` → `:datetime`
- `date` → `:date`
- `uuid` → `:uuid`

## Nested attributes with Rails

When you mark an association as `writable: true`, Apiwork expects `accepts_nested_attributes_for` in your model and uses it:

```ruby
# Your model (standard Rails):
class Post < ApplicationRecord
  has_many :comments
  accepts_nested_attributes_for :comments, allow_destroy: true
end

# Your schema:
class PostSchema < Apiwork::Schema::Base
  model Post

  has_many :comments,
    schema: CommentSchema,
    writable: true,        # Requires accepts_nested_attributes_for
    allow_destroy: true    # Auto-detected from model
end

# API request:
POST /api/v1/posts
{
  "post": {
    "title": "My Post",
    "comments": [                    # Use association name
      { "body": "New comment" },
      { "id": 5, "body": "Updated" },
      { "id": 6, "_destroy": true }
    ]
  }
}

# Apiwork transforms internally to Rails format:
{
  post: {
    title: "My Post",
    comments_attributes: [           # Rails expects _attributes suffix
      { body: "New comment" },
      { id: 5, body: "Updated" },
      { id: 6, _destroy: true }
    ]
  }
}

# Rails handles the rest - creating, updating, deleting comments
```

**How it works:**
1. Your model must have `accepts_nested_attributes_for :comments`
2. Mark the association `writable: true` in schema
3. API clients send `comments` array
4. Apiwork validates structure and transforms to `comments_attributes`
5. Rails' nested attributes handles creation/update/deletion

No custom logic. Just Rails' `accepts_nested_attributes_for` working as designed.

## Key transformation

By default, Apiwork transforms keys between client and server:

**Configuration**:

```ruby
Apiwork.configure do |config|
  config.output_key_format = :camel      # For responses (to client)
  config.input_key_format = :snake    # For requests (from client)
end
```

**Example**:

```ruby
# Client sends (camelCase):
{ "post": { "firstName": "John", "lastName": "Doe" } }

# Rails receives (snake_case):
{ "post" => { "first_name" => "John", "last_name" => "Doe" } }

# Rails responds (snake_case internally):
{ first_name: "John", last_name: "Doe" }

# Client receives (camelCase):
{ "post": { "firstName": "John", "lastName": "Doe" } }
```

This happens automatically!

## Next steps

Now that you understand the core concepts:

- **[API Definition](../api-definition/introduction.md)** - Learn all routing options
- **[Schemas](../schemas/introduction.md)** - Deep dive into schemas
- **[Contracts](../contracts/introduction.md)** - Master validation
- **[Controllers](../controllers/introduction.md)** - Use all helpers effectively
- **[Integration](../integration/full-stack-flow.md)** - See the complete picture
