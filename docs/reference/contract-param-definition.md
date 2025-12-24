---
order: 11
prev: false
next: false
---

# Contract::ParamDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/param_definition.rb#L12)

Defines params for query, body, or response.

Part of the Adapter DSL. Returned by [RequestDefinition#query](contract-request-definition#query),
[RequestDefinition#body](contract-request-definition#body), and [ResponseDefinition#body](contract-response-definition#body).
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #meta(**options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/param_definition.rb#L151)

Shorthand for `param :meta, type: :object do ... end`.

Use for response data that doesn't belong to the resource itself.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options` | `Hash` | options passed to param (e.g., optional: true) |

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

### #param(name, type: = nil, optional: = nil, default: = nil, enum: = nil, of: = nil, as: = nil, discriminator: = nil, value: = nil, visited_types: = nil, **options, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/param_definition.rb#L95)

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
