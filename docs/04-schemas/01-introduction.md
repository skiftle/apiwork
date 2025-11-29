# Schemas

Schemas define how data is serialized for API responses.

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :id
  attribute :title
  attribute :body
  attribute :created_at

  has_many :comments, schema: CommentSchema
end
```

## Naming Convention

Apiwork infers the schema from the contract name:

| Contract | Schema |
|----------|--------|
| `Api::V1::PostContract` | `Api::V1::PostSchema` |
| `Api::V1::CommentContract` | `Api::V1::CommentSchema` |

## Model Auto-Detection

Schemas auto-detect their model from the class name:

```ruby
class PostSchema < Apiwork::Schema::Base
  # Automatically connects to Post model
end
```

Explicit declaration:

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post
end
```

## Root Key

Override the default root key:

```ruby
class PostSchema < Apiwork::Schema::Base
  root :article, :articles
end
```

Responses use `article` for single objects and `articles` for collections.

## Connecting to Contract

In the contract, use `schema!` to enable serialization:

```ruby
class PostContract < Apiwork::Contract::Base
  schema!  # Connects to PostSchema
end
```
