---
order: 17
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L87)

Registers an API builder for this capability.

API builders run once per API at initialization time to register
shared types used across all contracts.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Builder::API::Base>`, `nil` | `nil` | The builder class. |

</div>

**Returns**

`void`

**See also**

- [Builder::API::Base](/reference/apiwork/adapter/builder/api/base)

---

### .capability_name

`.capability_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L47)

The name for this capability.

Used for configuration options, translation keys, and [Adapter::Base.skip_capability](/reference/apiwork/adapter/base#skip-capability).

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Symbol`, `nil` | `nil` | The capability name. |

</div>

**Returns**

`Symbol`, `nil`

---

### .contract_builder

`.contract_builder(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L106)

Registers a contract builder for this capability.

Contract builders run per contract to add capability-specific
parameters and response shapes.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Builder::Contract::Base>`, `nil` | `nil` | The builder class. |

</div>

**Returns**

`void`

**See also**

- [Builder::Contract::Base](/reference/apiwork/adapter/builder/contract/base)

---

### .operation

`.operation(klass = nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L125)

Registers an operation for this capability.

Operations run at request time to process data based on
request parameters.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Operation::Base>`, `nil` | `nil` | The operation class. |

</div>

**Returns**

`void`

**See also**

- [Operation::Base](/reference/apiwork/adapter/capability/operation/base)

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

- [Configuration::Option](/reference/apiwork/configuration/option)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L59)

Registers a request transformer for this capability.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`transformer_class`** | `Class<Transformer::Request::Base>` |  | The transformer class. |

</div>

**Returns**

`void`

**See also**

- [Transformer::Request::Base](/reference/apiwork/adapter/capability/transformer/request/base)

---

### .response_transformer

`.response_transformer(transformer_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/base.rb#L71)

Registers a response transformer for this capability.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`transformer_class`** | `Class<Transformer::Response::Base>` |  | The transformer class. |

</div>

**Returns**

`void`

**See also**

- [Transformer::Response::Base](/reference/apiwork/adapter/capability/transformer/response/base)

---
