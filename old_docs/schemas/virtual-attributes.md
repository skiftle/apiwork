# Virtual Attributes

Virtual attributes are fields that don't exist in your database. They're computed on the fly.

## Basic example

```ruby
class PostSchema < Apiwork::Schema::Base
  model Post

  attribute :id
  attribute :title
  attribute :body

  # Virtual attribute
  attribute :word_count, type: :integer

  def word_count
    object.body.to_s.split.size
  end
end
```

Response:

```json
{
  "post": {
    "id": 1,
    "title": "My Post",
    "body": "This is the content...",
    "wordCount": 42
  }
}
```

The `word_count` method is called for each post, with `object` being the Post record.

## When to use virtual attributes

**Display computed values:**
```ruby
attribute :full_name, type: :string

def full_name
  "#{object.first_name} #{object.last_name}"
end
```

**Format existing attributes:**
```ruby
attribute :formatted_price, type: :string

def formatted_price
  "$#{object.price.round(2)}"
end
```

**Aggregate related data:**
```ruby
attribute :comment_count, type: :integer

def comment_count
  object.comments.count
end
```

**Conditional logic:**
```ruby
attribute :status_label, type: :string

def status_label
  object.published? ? 'Live' : 'Draft'
end
```

## The object method

Inside attribute methods, `object` is the current record being serialized:

```ruby
attribute :full_name

def full_name
  object.first_name  # object is the User instance
end
```

You can call any method on the model:

```ruby
attribute :is_new, type: :boolean

def is_new
  object.created_at > 7.days.ago
end
```

## Performance considerations

Virtual attributes are computed for every serialized record:

```ruby
attribute :comment_count, type: :integer

def comment_count
  object.comments.count  # N+1 query!
end
```

This causes an N+1 query. Better:

```ruby
attribute :comment_count, type: :integer

def comment_count
  object.comments.size  # Uses preloaded count
end
```

Make sure to eager load in your controller:

```ruby
def index
  posts = Post.includes(:comments)
  respond_with query(posts)
end
```

Or use a counter cache:

```ruby
# Migration
add_column :posts, :comments_count, :integer, default: 0

# Model
class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
end

# Schema - just use the column
attribute :comments_count, type: :integer
```

No virtual attribute needed!

## Wrapping existing attributes

Override an attribute's serialization:

```ruby
attribute :title

def title
  object.title.upcase  # Always uppercase
end
```

Or add default values:

```ruby
attribute :status

def status
  object.status || 'draft'
end
```

## Virtual writable attributes

Virtual attributes can be writable:

```ruby
attribute :full_name, writable: true, type: :string

def full_name=(value)
  parts = value.split(' ', 2)
  object.first_name = parts[0]
  object.last_name = parts[1]
end

def full_name
  "#{object.first_name} #{object.last_name}"
end
```

Now users can POST:

```json
{
  "user": {
    "fullName": "Alice Smith"
  }
}
```

And it sets `first_name` and `last_name`.

Use this sparingly - usually better to accept the actual fields.

## Accessing context

The `context` hash contains request-specific data:

```ruby
attribute :is_owner, type: :boolean

def is_owner
  object.user_id == context[:current_user]&.id
end
```

Set context in your controller:

```ruby
def show
  user = User.find(params[:id])
  respond_with user, context: { current_user: current_user }
end
```

Common context uses:

```ruby
# Admin-only fields
attribute :internal_notes, if: -> { context[:admin] }

# User-specific data
attribute :is_bookmarked, type: :boolean

def is_bookmarked
  return false unless context[:current_user]
  context[:current_user].bookmarks.exists?(post_id: object.id)
end

# Localization
attribute :title

def title
  object.translations[context[:locale]] || object.title
end
```

## Filterable virtual attributes

Virtual attributes usually aren't filterable (no database column to query).

But you can make them filterable if you define the SQL:

```ruby
attribute :full_name,
  filterable: true,
  filter_sql: "CONCAT(first_name, ' ', last_name)"

def full_name
  "#{object.first_name} #{object.last_name}"
end
```

Now:
```
GET /api/v1/users?filter[full_name][contains]=Alice
```

Generates SQL:
```sql
WHERE CONCAT(first_name, ' ', last_name) LIKE '%Alice%'
```

## Sortable virtual attributes

Same for sorting:

```ruby
attribute :full_name,
  sortable: true,
  sort_sql: "CONCAT(first_name, ' ', last_name)"
```

Enables:
```
GET /api/v1/users?sort[full_name]=asc
```

## Caching virtual attributes

For expensive computations, cache the result:

```ruby
attribute :markdown_html, type: :string

def markdown_html
  Rails.cache.fetch(['post', object.id, 'markdown', object.updated_at]) do
    MarkdownRenderer.render(object.body)
  end
end
```

The cache key includes `updated_at` so it invalidates when the post changes.

## Virtual associations

You can define virtual associations:

```ruby
has_many :recent_comments, schema: Api::V1::CommentSchema

def recent_comments
  object.comments.where('created_at > ?', 7.days.ago)
end
```

This works like a regular association but uses your custom logic.

## Testing virtual attributes

Test them like regular attributes:

```ruby
# spec/schemas/api/v1/post_schema_spec.rb
RSpec.describe Api::V1::PostSchema do
  let(:post) { create(:post, body: 'This has five words') }
  let(:schema) { described_class.new(post) }

  it 'computes word count' do
    expect(schema.word_count).to eq(5)
  end

  it 'serializes correctly' do
    json = schema.serialize
    expect(json[:word_count]).to eq(5)
  end
end
```

## Next steps

- **[Writable Associations](./writable-associations.md)** - Nested creates/updates
- **[Associations](./associations.md)** - belongs_to, has_many, has_one
- **[Introduction](./introduction.md)** - Back to schemas overview
