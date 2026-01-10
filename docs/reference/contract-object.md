---
order: 18
prev: false
next: false
---

# Contract::Object

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L23)

Block context for defining request/response structure.

Accessed via `body do`, `query do`, or `param :x, type: :object do`
inside contract actions. Use [#param](#param) to define fields.

**Example: Request body**

```ruby
body do
  param :title, type: :string
  param :amount, type: :decimal
end
```

**Example: Inline nested object**

```ruby
param :customer, type: :object do
  param :name, type: :string
end
```

## Instance Methods

### #meta

`#meta(optional: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L199)

Shorthand for `param :meta, type: :object do ... end`.

Use for response data that doesn't belong to the resource itself.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `optional` | `Boolean` | whether meta can be omitted (default: false) |

**Example: Required meta (default)**

```ruby
response do
  body do
    meta do
      param :generated_at, type: :datetime
    end
  end
end
```

**Example: Optional meta**

```ruby
response do
  body do
    meta optional: true do
      param :api_version, type: :string
    end
  end
end
```

---

### #param

`#param(name, as: nil, default: nil, deprecated: nil, description: nil, discriminator: nil, enum: nil, example: nil, format: nil, max: nil, min: nil, nullable: nil, of: nil, optional: nil, required: nil, type: nil, value: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/object.rb#L79)

Defines a parameter/field in a request or response body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `type` | `Symbol` | data type (:string, :integer, :boolean, :datetime, :date, :uuid, :object, :array, :decimal, :float, :literal, :union, or custom type) |
| `optional` | `Boolean` | whether field can be omitted (default: false) |
| `default` | `Object` | value when field is nil |
| `enum` | `Array, Symbol` | allowed values, or reference to registered enum |
| `of` | `Symbol` | element type for :array |
| `as` | `Symbol` | serialize field under different name |
| `discriminator` | `Symbol` | discriminator field for :union type |
| `value` | `Object` | exact value for :literal type |
| `deprecated` | `Boolean` | mark field as deprecated |
| `description` | `String` | field description for docs |
| `example` | `Object` | example value for docs |
| `format` | `String` | format hint (e.g. 'email', 'uri') |
| `max` | `Integer` | maximum value (numeric) or length (string/array) |
| `min` | `Integer` | minimum value (numeric) or length (string/array) |
| `nullable` | `Boolean` | whether null is allowed |
| `required` | `Boolean` | alias for optional: false (for readability) |

**Returns**

`void`

**See also**

- [Contract::Object](contract-object)
- [Contract::Union](contract-union)

**Example: Basic param**

```ruby
param :amount, type: :decimal
```

**Example: Inline object**

```ruby
param :customer, type: :object do
  param :name, type: :string
end
```

**Example: Inline union**

```ruby
param :payment_method, type: :union, discriminator: :type do
  variant tag: 'card', type: :object do
    param :last_four, type: :string
  end
  variant tag: 'bank', type: :object do
    param :account_number, type: :string
  end
end
```

---
