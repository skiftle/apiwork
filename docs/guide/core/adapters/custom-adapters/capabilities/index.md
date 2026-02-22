---
order: 4
title: Capabilities
---

# Introduction

A capability encapsulates a specific feature (filtering, pagination, sorting) with its own configuration, transformers, builders, and operations. While each capability is self-contained, all capabilities operate on the same response data in sequence, so their effects combine. Capabilities inherit from [`Adapter::Capability::Base`](/reference/adapter/capability/base).

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

## Components

A capability can have up to five components:

| Component | Phase | Purpose |
|-----------|-------|---------|
| Options | Configuration | Configurable settings |
| Request transformer | Runtime | Modify incoming requests |
| Response transformer | Runtime | Modify outgoing responses |
| API builder | Introspection | Register API-level types |
| Contract builder | Introspection | Register contract-level types |
| Operation | Runtime + Introspection | Process data and define metadata shape |

Not all capabilities need all components. A simple capability might only have an operation.

## Capability DSL

### capability_name

Sets the capability name for configuration lookup and `skip_capability`:

```ruby
capability_name :filtering
```

### option

Defines a configuration option:

```ruby
option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
option :default_size, type: :integer, default: 20
```

### request_transformer

Registers a request transformer:

```ruby
request_transformer RequestTransformer
```

### response_transformer

Registers a response transformer:

```ruby
response_transformer ResponseTransformer
```

### api_builder

Registers an API builder (class or block):

```ruby
api_builder APIBuilder

# Or with a block
api_builder do
  object(:my_type) do |object|
    object.string(:name)
  end
end
```

### contract_builder

Registers a contract builder (class or block):

```ruby
contract_builder ContractBuilder

# Or with a block
contract_builder do
  # access scope.filterable_attributes, etc.
end
```

### operation

Registers an operation (class or block):

```ruby
operation Operation

# Or with a block
operation do
  # process data
end
```

## Three Phases

### Introspection Phase

Runs once when the API loads:

1. **API builders** register shared types (enums, filter types, pagination types)
2. **Contract builders** register contract-specific types based on representations

### Runtime Phase

Runs for every request:

1. **Request transformers** modify incoming data before/after validation
2. **Operations** apply the capability logic (filter, sort, paginate)
3. **Response transformers** modify outgoing data

## Standard Capabilities

The [standard adapter](../../standard-adapter/) includes these capabilities:

| Capability | Purpose |
|------------|---------|
| Filtering | Filter records by attribute values |
| Sorting | Order records by attributes |
| Pagination | Paginate results (offset or cursor) |
| Including | Eager load associations |
| Writing | Handle nested attributes for create/update |

## Next Steps

- [Options](./options.md) - Configuration and cascading
- [Transformers](./transformers.md) - Request and response transformers
- [API Builders](./api-builders.md) - API-phase type registration
- [Contract Builders](./contract-builders.md) - Contract-phase type registration
- [Operations](./operations.md) - Runtime data processing

#### See also

- [Capability::Base reference](/reference/adapter/capability/base)
- [Standard Adapter](../../standard-adapter/)
