---
order: 12
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L24)

Base class for adapters.

Subclass to create custom adapters with different response formats.
Override [#prepare_record](#prepare-record), [#prepare_collection](#prepare-collection), [#render_record](#render-record),
[#render_collection](#render-collection), and [#render_error](#render-error) to customize behavior.

**Example: Custom adapter**

```ruby
class BillingAdapter < Apiwork::Adapter::Base
  adapter_name :billing

  def render_record(data, schema_class, state)
    { data: data, meta: { adapter: 'billing' } }
  end

  def render_error(issues, layer, state)
    { errors: issues.map(&:to_h) }
  end
end
```

## Class Methods

### .adapter_name

`.adapter_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L36)

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

### .api_builder

`.api_builder(builder_class = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L52)

Sets or gets the API builder class.

The builder registers API-level types and query parameters
during introspection.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `builder_class` | `Class` | builder with `.build(registrar, capabilities)` (optional) |

**Returns**

`Class`, `nil`

**Example**

```ruby
api_builder MyAPIBuilder
```

---

### .contract_builder

`.contract_builder(builder_class = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L68)

Sets or gets the contract builder class.

The builder registers contract-level types and action parameters
during introspection.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `builder_class` | `Class` | builder with `.build(registrar, schema_class, actions)` (optional) |

**Returns**

`Class`, `nil`

**Example**

```ruby
contract_builder MyContractBuilder
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

### .transform_request

`.transform_request(*transformers, post: false)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L88)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L106)

Registers response transformers.

Transformers process the response after rendering.

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

### #prepare_collection

`#prepare_collection(collection, _schema_class, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L180)

Prepares a collection before serialization.

Override to add filtering, sorting, pagination, or eager loading.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `collection` | `Enumerable` | collection to prepare |
| `_schema_class` | `Class` | the schema class |
| `_state` | `Adapter::RenderState` | render context |

**Returns**

`Hash` — prepared result with :data and :metadata keys

---

### #prepare_error

`#prepare_error(issues, _layer, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L193)

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

### #prepare_record

`#prepare_record(record, _schema_class, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L167)

Prepares a record before serialization.

Override to add eager loading, validation, or transformation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `ActiveRecord::Base` | record to prepare |
| `_schema_class` | `Class` | the schema class |
| `_state` | `Adapter::RenderState` | render context |

**Returns**

`ActiveRecord::Base` — the prepared record

---

### #render_collection

`#render_collection(result, _schema_class, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L219)

Renders a collection response.

Override to customize the response structure.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `result` | `Hash` | prepared collection with :data and :metadata |
| `_schema_class` | `Class` | the schema class |
| `_state` | `Adapter::RenderState` | render context |

**Returns**

`Hash` — the response body

---

### #render_error

`#render_error(issues, _layer, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L232)

Renders an error response.

Override to customize the error structure.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `issues` | `Array<Issue>` | prepared error issues |
| `_layer` | `Symbol` | error layer (:contract, :domain, :http) |
| `_state` | `Adapter::RenderState` | render context |

**Returns**

`Hash` — the error response body

---

### #render_record

`#render_record(data, _schema_class, _state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L206)

Renders a single record response.

Override to customize the response structure.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `Hash` | serialized record data |
| `_schema_class` | `Class` | the schema class |
| `_state` | `Adapter::RenderState` | render context |

**Returns**

`Hash` — the response body

---
