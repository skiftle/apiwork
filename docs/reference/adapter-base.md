---
order: 12
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L18)

Base class for adapters.

Subclass to create custom adapters with different response formats.
Configure with [representation](representation) for serialization and [document](document) for response wrapping.

**Example: Custom adapter**

```ruby
class BillingAdapter < Apiwork::Adapter::Base
  adapter_name :billing

  representation BillingRepresentation
  document BillingDocument
end
```

## Class Methods

### .adapter_name

`.adapter_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L30)

Sets or gets the adapter name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, String` | adapter name (optional) |

**Returns**

`Symbol`, `nil`

**Example**

```ruby
adapter_name :billing
```

---

### .capability

`.capability(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L47)

Registers a capability for this adapter.

Capabilities are self-contained concerns (pagination, filtering, etc.)
that handle both introspection and runtime behavior.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Capability::Base subclass |

**Returns**

`void`

**Example**

```ruby
capability Pagination
capability Filtering
```

---

### .document

`.document(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L106)

Sets or gets the document class.

Document defines response envelopes and wraps serialized data.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Document::Base subclass (optional) |

**Returns**

`Class`, `nil`

**Example**

```ruby
document StandardDocument
```

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L50)

Defines a configuration option.

For nested options, use `type: :hash` with a block. Inside the block,
call `option` to define child options.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | option name |
| `type` | `Symbol` | :symbol, :string, :integer, :boolean, or :hash |
| `default` | `Object, nil` | default value |
| `enum` | `Array, nil` | allowed values |

**Returns**

`void`

**See also**

- [Configuration::Option](configuration-option)

**Example: Symbol option**

```ruby
option :locale, type: :symbol, default: :en
```

**Example: String option with enum**

```ruby
option :version, type: :string, default: '5', enum: %w[4 5]
```

**Example: Nested options**

```ruby
option :pagination, type: :hash do
  option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
  option :default_size, type: :integer, default: 20
  option :max_size, type: :integer, default: 100
end
```

---

### .representation

`.representation(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L91)

Sets or gets the representation class.

Representation defines API objects (resources, errors) and handles serialization.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Representation::Base subclass (optional) |

**Returns**

`Class`, `nil`

**Example**

```ruby
representation StandardRepresentation
```

---

### .skip_capability

`.skip_capability(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L69)

Skips an inherited capability by name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the capability_name to skip |

**Returns**

`void`

**Example**

```ruby
skip_capability :pagination
```

---

### .transform_request

`.transform_request(*transformers, post: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L126)

Registers request transformers.

Use `post: false` (default) for pre-validation transforms.
Use `post: true` for post-validation transforms.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transformers` | `Array<Class>` | transformer classes with `.transform(request, api_class:)` |
| `post` | `Boolean` | run after validation (default: false) |

**Returns**

`void`

**Example: Pre-validation transform**

```ruby
transform_request KeyNormalizer
```

**Example: Post-validation transform**

```ruby
transform_request OpFieldTransformer, post: true
```

---

### .transform_response

`.transform_response(*transformers, post: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L145)

Registers response transformers.

Use `post: false` (default) for pre-serialization transforms.
Use `post: true` for post-serialization transforms.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transformers` | `Array<Class>` | transformer classes with `.transform(response, api_class:)` |
| `post` | `Boolean` | run after other transforms (default: false) |

**Returns**

`void`

**Example**

```ruby
transform_response KeyTransformer
```

---

## Instance Methods

### #prepare_error

`#prepare_error(issues, _layer, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L221)

Prepares error issues before rendering.

Override to transform or enrich error data.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `issues` | `Array<Issue>` | error issues |
| `_layer` | `Symbol` | error layer (:contract, :domain, :http) |
| `_state` | `Adapter::RenderState` | render context |

**Returns**

Array&lt;[Issue](issue)&gt; — the prepared issues

---
