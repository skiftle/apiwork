---
order: 11
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L26)

Base class for adapters.

The engine of an API. Handles both introspection (generating types from
representations) and runtime (processing requests through capabilities,
serializing, and wrapping responses). The class declaration acts as a manifest.

**Example**

```ruby
class MyAdapter < Apiwork::Adapter::Base
  adapter_name :my

  resource_serializer Serializer::Resource::Default
  error_serializer Serializer::Error::Default

  member_wrapper Wrapper::Member::Default
  collection_wrapper Wrapper::Collection::Default
  error_wrapper Wrapper::Error::Default

  capability Capability::Filtering
  capability Capability::Pagination
end
```

## Class Methods

### .adapter_name

`.adapter_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L38)

The adapter name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, String` |  |

**Returns**

`Symbol`, `nil`

**Example**

```ruby
adapter_name :my
```

---

### .capability

`.capability(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L55)

Registers a capability for this adapter.

Capabilities are self-contained concerns (pagination, filtering, etc.)
that handle both introspection and runtime behavior.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Capability::Base](adapter-capability-base) subclass |

**Returns**

`void`

**Example**

```ruby
capability Capability::Filtering
capability Capability::Pagination
```

---

### .collection_wrapper

`.collection_wrapper(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L136)

The collection wrapper class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Wrapper::Collection::Base](adapter-wrapper-collection-base) subclass |

**Returns**

`Class`, `nil`

**Example**

```ruby
collection_wrapper Wrapper::Collection::Default
```

---

### .error_serializer

`.error_serializer(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L110)

The error serializer class.

Handles serialization of errors.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Serializer::Error::Base](adapter-serializer-error-base) subclass |

**Returns**

`Class`, `nil`

**Example**

```ruby
error_serializer Serializer::Error::Default
```

---

### .error_wrapper

`.error_wrapper(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L149)

The error wrapper class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Wrapper::Error::Base](adapter-wrapper-error-base) subclass |

**Returns**

`Class`, `nil`

**Example**

```ruby
error_wrapper Wrapper::Error::Default
```

---

### .member_wrapper

`.member_wrapper(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L123)

The member wrapper class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Wrapper::Member::Base](adapter-wrapper-member-base) subclass |

**Returns**

`Class`, `nil`

**Example**

```ruby
member_wrapper Wrapper::Member::Default
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

### .resource_serializer

`.resource_serializer(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L95)

The resource serializer class.

Handles serialization of records and collections.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Serializer::Resource::Base](adapter-serializer-resource-base) subclass |

**Returns**

`Class`, `nil`

**Example**

```ruby
resource_serializer Serializer::Resource::Default
```

---

### .skip_capability

`.skip_capability(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L73)

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
