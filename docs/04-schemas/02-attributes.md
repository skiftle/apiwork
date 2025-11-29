# Attributes

Attributes define the fields included in serialized output.

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :id
  attribute :title
  attribute :body
  attribute :created_at
end
```

## Options

### filterable

Enable filtering on this attribute:

```ruby
attribute :title, filterable: true
```

See [Filtering](../09-adapters/02-apiwork-adapter/03-filtering.md).

### sortable

Enable sorting on this attribute:

```ruby
attribute :created_at, sortable: true
```

See [Sorting](../09-adapters/02-apiwork-adapter/04-sorting.md).

### writable

Allow this attribute in create/update requests:

```ruby
attribute :title, writable: true
```

### nullable

Allow null values:

```ruby
attribute :deleted_at, nullable: true
```

### min / max

Validation constraints:

```ruby
attribute :name, min: 2, max: 50
```

### encode

Transform value when serializing (output):

```ruby
attribute :email, encode: ->(value) { value&.downcase }
```

### decode

Transform value when deserializing (input):

```ruby
attribute :email, decode: ->(value) { value&.upcase }
```

## Combining Options

```ruby
attribute :title, writable: true, filterable: true, sortable: true
```

## with_options

Apply options to multiple attributes:

```ruby
with_options filterable: true, sortable: true do
  attribute :id
  attribute :created_at
  attribute :updated_at

  with_options writable: true do
    attribute :title
    attribute :body
  end
end
```

## Computed Attributes

Attributes don't need to map to model columns. Define a method with the same name:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :full_title, type: :string

  def full_title
    "#{object.title} - #{object.id}"
  end
end
```

The `object` accessor returns the underlying model instance.

### Working with Relations

Access and transform the model's associations:

```ruby
class PostSchema < Apiwork::Schema::Base
  attribute :comment_count, type: :integer
  attribute :latest_comment_author, type: :string

  def comment_count
    object.comments.count
  end

  def latest_comment_author
    object.comments.order(created_at: :desc).first&.author
  end
end
```

Note: Apiwork cannot automatically eager load associations used in computed attributes. To avoid N+1 queries, add `includes` in your controller:

```ruby
def index
  posts = Post.includes(:comments)
  render_collection(posts)
end
```

Important: Always specify `type:` for computed attributes. Without a database column, Apiwork cannot infer the type.
