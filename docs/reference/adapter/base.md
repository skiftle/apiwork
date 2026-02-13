---
order: 12
prev: false
next: false
---

# Base

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L39)

The adapter name for this adapter.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Symbol`, `String`, `nil` | `nil` | The adapter name. |

</div>

**Returns**

`Symbol`, `nil`

**Example**

```ruby
adapter_name :my
```

---

### .capability

`.capability(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L57)

Registers a capability for this adapter.

Capabilities are self-contained concerns (pagination, filtering, etc.)
that handle both introspection and runtime behavior.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`klass`** | `Class<Capability::Base>` |  | The capability class. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L175)

Sets the wrapper class for collection responses.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Wrapper::Collection::Base>`, `nil` | `nil` | The wrapper class. |

</div>

**Returns**

Class&lt;[Wrapper::Collection::Base](/reference/adapter/wrapper/collection/base)&gt;, `nil`

**Example**

```ruby
collection_wrapper Wrapper::Collection::Default
```

---

### .error_serializer

`.error_serializer(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L123)

Sets the serializer class for errors.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Serializer::Error::Base>`, `nil` | `nil` | The serializer class. |

</div>

**Returns**

Class&lt;[Serializer::Error::Base](/reference/adapter/serializer/error/base)&gt;, `nil`

**Example**

```ruby
error_serializer Serializer::Error::Default
```

---

### .error_wrapper

`.error_wrapper(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L201)

Sets the wrapper class for error responses.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Wrapper::Error::Base>`, `nil` | `nil` | The wrapper class. |

</div>

**Returns**

Class&lt;[Wrapper::Error::Base](/reference/adapter/wrapper/error/base)&gt;, `nil`

**Example**

```ruby
error_wrapper Wrapper::Error::Default
```

---

### .member_wrapper

`.member_wrapper(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L149)

Sets the wrapper class for single-record responses.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Wrapper::Member::Base>`, `nil` | `nil` | The wrapper class. |

</div>

**Returns**

Class&lt;[Wrapper::Member::Base](/reference/adapter/wrapper/member/base)&gt;, `nil`

**Example**

```ruby
member_wrapper Wrapper::Member::Default
```

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L56)

Defines a configuration option.

For nested options, use `type: :hash` with a block. Inside the block,
call `option` to define child options.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The option name. |
| **`type`** | `Symbol<:boolean, :hash, :integer, :string, :symbol>` |  | The option type. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `enum` | `Array`, `nil` | `nil` | The allowed values. |

</div>

**Returns**

`void`

**See also**

- [Configuration::Option](/reference/configuration/option)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L97)

Sets the serializer class for records and collections.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Serializer::Resource::Base>`, `nil` | `nil` | The serializer class. |

</div>

**Returns**

Class&lt;[Serializer::Resource::Base](/reference/adapter/serializer/resource/base)&gt;, `nil`

**Example**

```ruby
resource_serializer Serializer::Resource::Default
```

---

### .skip_capability

`.skip_capability(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L76)

Skips an inherited capability by name.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The capability name to skip. |

</div>

**Returns**

`void`

**Example**

```ruby
skip_capability :pagination
```

---
