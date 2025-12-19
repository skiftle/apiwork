---
order: 56
prev: false
next: false
---

# Definition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L5)

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L6)

Returns the value of attribute action_name.

---

### #as_json()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L35)

---

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L6)

Returns the value of attribute contract_class.

---

### #initialize(type:, contract_class:, action_name: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L11)

**Returns**

`Definition` — a new instance of Definition

---

### #introspect(locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L31)

---

### #meta(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L130)

Defines a metadata object for request payloads.

Meta is an optional object for request-level metadata like
request IDs, client info, or idempotency keys. The adapter
may pre-populate common meta fields.

**Example**

```ruby
request do
  meta do
    param :request_id, type: :uuid
    param :client_version, type: :string, optional: true
  end
end
```

---

### #param(name, type: = nil, optional: = nil, default: = nil, enum: = nil, of: = nil, as: = nil, discriminator: = nil, value: = nil, visited_types: = nil, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L85)

Defines a parameter/field in a request or response body.

rubocop:disable Metrics/ParameterLists

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | field name |
| `type` | `Symbol` | data type (:string, :integer, :boolean, :datetime, :date,
:uuid, :object, :array, :decimal, :float, :literal, :union, or custom type) |
| `optional` | `Boolean` | whether field can be omitted (default: false) |
| `default` | `Object` | value when field is nil |
| `enum` | `Array, Symbol` | allowed values, or reference to registered enum |
| `of` | `Symbol` | element type for :array |
| `as` | `Symbol` | serialize field under different name |
| `discriminator` | `Symbol` | discriminator field for :union type |
| `value` | `Object` | exact value for :literal type |
| `options` | `Hash` | a customizable set of options |

**Example: Basic types**

```ruby
param :title, type: :string
param :count, type: :integer, min: 0
param :active, type: :boolean, default: true
```

**Example: With enum**

```ruby
param :status, enum: %w[draft published archived]
param :role, enum: :user_role  # reference to registered enum
```

**Example: Nested object**

```ruby
param :address, type: :object do
  param :street, type: :string
  param :city, type: :string
end
```

**Example: Array of objects**

```ruby
param :items, type: :array, of: :line_item do
  param :product_id, type: :integer
  param :quantity, type: :integer, min: 1
end
```

---

### #params()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L6)

Returns the value of attribute params.

---

### #resolve_option(name, subkey = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L18)

---

### #type()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L6)

Returns the value of attribute type.

---

### #unwrapped_union?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L39)

**Returns**

`Boolean` — 

---

### #validate(data, options = {})

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/definition.rb#L297)

---
