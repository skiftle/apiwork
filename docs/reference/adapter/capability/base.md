---
order: 16
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L28)

Base class for adapter capabilities.

A capability encapsulates a specific feature (filtering, pagination, sorting)
with its own configuration, transformers, builders, and operations. While each
capability is self-contained, all capabilities operate on the same response data
in sequence, so their effects combine.

**Example: Filtering capability**

```ruby
class Filtering < Adapter::Capability::Base
  capability_name :filtering

  option :strategy, type: :symbol, default: :simple

  request_transformer RequestTransformer
  api_builder APIBuilder
  contract_builder ContractBuilder
  operation Operation
end
```

## Class Methods

### .api_builder

`.api_builder(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L91)

Registers an API builder for this capability.

API builders run once per API at initialization time to register
shared types used across all contracts.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class, nil` | a [Builder::API::Base](/reference/adapter/builder/api/base) subclass |

**Returns**

`void`

**See also**

- [Builder::API::Base](/reference/adapter/builder/api/base)

---

### .capability_name

`.capability_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L46)

Sets or returns the capability name.

Used for configuration options, translation keys, and [Adapter::Base.skip_capability](/reference/adapter/base#skip-capability).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | the capability name |

**Returns**

`Symbol`, `nil` — the capability name

---

### .contract_builder

`.contract_builder(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L109)

Registers a contract builder for this capability.

Contract builders run per contract to add capability-specific
parameters and response shapes.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class, nil` | a [Builder::Contract::Base](/reference/adapter/builder/contract/base) subclass |

**Returns**

`void`

**See also**

- [Builder::Contract::Base](/reference/adapter/builder/contract/base)

---

### .operation

`.operation(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L127)

Registers an operation for this capability.

Operations run at request time to process data based on
request parameters.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class, nil` | an [Operation::Base](/reference/adapter/capability/operation/base) subclass |

**Returns**

`void`

**See also**

- [Operation::Base](/reference/adapter/capability/operation/base)

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

### .request_transformer

`.request_transformer(transformer_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L57)

Registers a request transformer for this capability.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transformer_class` | `Class` | a [Transformer::Request::Base](/reference/adapter/capability/transformer/request/base) subclass |

**Returns**

`void`

**See also**

- [Transformer::Request::Base](/reference/adapter/capability/transformer/request/base)

---

### .response_transformer

`.response_transformer(transformer_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L72)

Registers a response transformer for this capability.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `transformer_class` | `Class` | a [Transformer::Response::Base](/reference/adapter/capability/transformer/response/base) subclass |

**Returns**

`void`

**See also**

- [Transformer::Response::Base](/reference/adapter/capability/transformer/response/base)

---
