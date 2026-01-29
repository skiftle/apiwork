---
order: 11
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L20)

Base class for adapters.

Subclass to create custom adapters with different response formats.
Configure with [representation](representation) for serialization and document classes for response wrapping.

**Example: Custom adapter**

```ruby
class BillingAdapter < Apiwork::Adapter::Base
  adapter_name :billing

  representation BillingRepresentation
  record_document BillingRecordDocument
  collection_document BillingCollectionDocument
  error_document BillingErrorDocument
end
```

## Class Methods

### .adapter_name

`.adapter_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L32)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L49)

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

### .collection_document

`.collection_document(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L134)

Sets or gets the collection document class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Document::Base subclass (optional) |

**Returns**

`Class`

**Example**

```ruby
collection_document CustomCollectionDocument
```

---

### .error_document

`.error_document(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L147)

Sets or gets the error document class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Document::Base subclass (optional) |

**Returns**

`Class`

**Example**

```ruby
error_document CustomErrorDocument
```

---

### .error_serializer

`.error_serializer(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L108)

Sets or gets the error serializer class.

Error serializer handles serialization of errors.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Serializer::Error::Base subclass (optional) |

**Returns**

`Class`, `nil`

**Example**

```ruby
error_serializer Serializer::Error::Default
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

### .record_document

`.record_document(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L121)

Sets or gets the record document class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Document::Base subclass (optional) |

**Returns**

`Class`

**Example**

```ruby
record_document CustomRecordDocument
```

---

### .resource_serializer

`.resource_serializer(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L93)

Sets or gets the resource serializer class.

Resource serializer handles serialization of records and collections.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a Serializer::Resource::Base subclass (optional) |

**Returns**

`Class`, `nil`

**Example**

```ruby
resource_serializer Serializer::Resource::Default
```

---

### .skip_capability

`.skip_capability(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L71)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L167)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L186)

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
