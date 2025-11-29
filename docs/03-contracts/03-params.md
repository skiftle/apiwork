# Params

Params define the structure and validation of input data.

## Basic Types

```ruby
param :title, type: :string
param :count, type: :integer
param :price, type: :float
param :active, type: :boolean
param :birth_date, type: :date
param :created_at, type: :datetime
param :start_time, type: :time
param :id, type: :uuid
```

## Required & Optional

```ruby
# Required by default in body
param :title, type: :string

# Explicitly optional
param :subtitle, type: :string, required: false

# Query params are optional by default
query do
  param :q, type: :string  # optional
  param :page, type: :integer, required: true  # required
end
```

## Default Values

```ruby
param :published, type: :boolean, default: false
param :status, type: :string, default: 'draft'
param :tags, type: :array, default: []
```

## Nullable

Allow null values:

```ruby
param :archived_at, type: :datetime, nullable: true
```

## Enums

Restrict to specific values:

```ruby
param :status, type: :string, enum: %w[draft published archived]
```

Or use a defined enum type:

```ruby
# In API definition
enum :post_status, values: %w[draft published archived]

# In contract
param :status, type: :string, enum: :post_status
```

## Min & Max

For numeric values:

```ruby
param :age, type: :integer, min: 0, max: 150
param :price, type: :float, min: 0.01
```

For string length:

```ruby
param :title, type: :string, min: 1, max: 255
```

For array size:

```ruby
param :tags, type: :array, min: 1, max: 10
```

## Arrays

```ruby
# Array of strings
param :tags, type: :array, of: :string

# Array of integers
param :ids, type: :array, of: :integer

# Array of objects
param :posts, type: :array do
  param :title, type: :string
  param :body, type: :string
end
```

## Nested Objects

```ruby
param :post, type: :object do
  param :title, type: :string
  param :body, type: :string
  param :author, type: :object do
    param :name, type: :string
    param :email, type: :string
  end
end
```

## Alias

Map external name to internal name:

```ruby
param :userName, type: :string, as: :user_name
```

The API accepts `userName` but the parsed data uses `user_name`.

## Custom Types

Reference types defined in the API:

```ruby
# In API definition
type :address do
  param :street, type: :string
  param :city, type: :string
end

# In contract
param :shipping_address, type: :address
```

See [Type System](../05-type-system/01-introduction.md).
