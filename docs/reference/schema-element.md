---
order: 63
prev: false
next: false
---

# Schema::Element

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L75)

Block context for defining JSON blob structure in schema attributes.

Used inside attribute blocks to define the shape of JSON/JSONB columns,
Rails store attributes, or any serialized data structure.

Only complex types are allowed at the top level:
- [#object](#object) for key-value structures
- [#array](#array) for ordered collections
- [#union](#union) for polymorphic structures

Inside these blocks, the full type DSL is available including
nested objects, arrays, primitives, and unions.

**Example: Object structure**

```ruby
attribute :settings do
  object do
    string :theme
    boolean :notifications
    integer :max_items, min: 1, max: 100
  end
end
```

**Example: Array of objects**

```ruby
attribute :addresses do
  array do
    object do
      string :street
      string :city
      string :zip
      boolean :primary
    end
  end
end
```

**Example: Nested structures**

```ruby
attribute :config do
  object do
    string :name
    array :tags do
      string
    end
    object :metadata do
      datetime :created_at
      datetime :updated_at
    end
  end
end
```

**Example: Union for polymorphic data**

```ruby
attribute :payment_details do
  union discriminator: :type do
    variant tag: 'card' do
      object do
        string :last_four
        string :brand
      end
    end
    variant tag: 'bank' do
      object do
        string :account_number
        string :routing_number
      end
    end
  end
end
```

## Instance Methods

### #array

`#array(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L146)

Defines an array structure.

The block is evaluated in [API::Element](api-element) context, where
exactly one element type must be defined.

**Returns**

`void`

**See also**

- [API::Element](api-element)

**Example: Array of strings**

```ruby
array do
  string
end
```

**Example: Array of objects**

```ruby
array do
  object do
    string :id
    string :name
  end
end
```

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L78)

**Returns**

`Symbol`, `nil` — the discriminator field for unions

---

### #object

`#object(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L113)

Defines an object structure.

The block is evaluated in [API::Object](api-object) context, providing
access to all field definition methods.

**Returns**

`void`

**See also**

- [API::Object](api-object)

**Example**

```ruby
object do
  string :name
  integer :count
  boolean :active
end
```

---

### #shape

`#shape`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L82)

**Returns**

[API::Object](api-object), [API::Union](api-union), `nil` — the shape builder

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L86)

**Returns**

`Symbol` — the element type (:object, :array, :union)

---

### #union

`#union(discriminator: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/element.rb#L183)

Defines a union structure for polymorphic data.

The block is evaluated in [API::Union](api-union) context, where
variants are defined using the `variant` method.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `discriminator` | `Symbol` | field name that identifies the variant |

**Returns**

`void`

**See also**

- [API::Union](api-union)

**Example**

```ruby
union discriminator: :type do
  variant tag: 'email' do
    object do
      string :address
    end
  end
  variant tag: 'sms' do
    object do
      string :phone_number
    end
  end
end
```

---
