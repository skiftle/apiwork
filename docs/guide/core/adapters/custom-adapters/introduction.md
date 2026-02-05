---
order: 1
---

# Introduction

Custom adapters give you complete control over how your API processes requests and renders responses. Build adapters for JSON:API, HAL, or entirely custom formats.

A custom adapter is a composition of components:

```ruby
class JsonApiAdapter < Apiwork::Adapter::Base
  adapter_name :json_api

  resource_serializer Serializer::Resource
  error_serializer Serializer::Error

  member_wrapper Wrapper::Member
  collection_wrapper Wrapper::Collection
  error_wrapper Wrapper::Error

  capability Capability::Filtering
  capability Capability::Pagination
end
```

## Components

| Component | Purpose |
|-----------|---------|
| Resource serializer | Converts records to response data |
| Error serializer | Converts errors to response data |
| Member wrapper | Structures single-record responses |
| Collection wrapper | Structures multi-record responses |
| Error wrapper | Structures error responses |
| Capabilities | Features like filtering, pagination, sorting |

## Two Phases

### Introspection

Runs once when the API loads:

- **Capabilities** register types (filter schemas, pagination schemas)
- **Serializers** register resource and error types
- **Wrappers** define response shapes

### Runtime

Runs for every request:

1. Transform request
2. Apply capabilities (filter, sort, paginate)
3. Serialize records
4. Wrap response
5. Transform response

## Adapter DSL

### adapter_name

The identifier used to reference this adapter. Required for registration with `Apiwork::Adapter.register`. Used as the key when selecting adapters in API definitions (`adapter :json_api`) and in i18n translation paths (`apiwork.adapters.json_api.capabilities...`).

```ruby
adapter_name :json_api
```

### resource_serializer

The class that converts records and collections to response data. Called with the representation class and returns serialized hashes. Also responsible for registering the resource type at introspection time.

```ruby
resource_serializer Serializer::Resource
```

### error_serializer

The class that converts [errors](../../errors/introduction.md) to response data. Called for contract errors (validation), domain errors (business logic), and HTTP errors. Also responsible for registering the error type at introspection time.

```ruby
error_serializer Serializer::Error
```

### member_wrapper

The class that structures single-record responses (show, create, update). Takes serialized data and wraps it in the final response format. Defines the response shape through its `shape` class method.

```ruby
member_wrapper Wrapper::Member
```

### collection_wrapper

The class that structures multi-record responses (index, collection actions). Takes serialized data and metadata (pagination, etc.) and wraps them in the final response format.

```ruby
collection_wrapper Wrapper::Collection
```

### error_wrapper

The class that structures error responses. Takes serialized error data and wraps it in the final response format.

```ruby
error_wrapper Wrapper::Error
```

### capability

Registers a capability. Capabilities contribute to both introspection (registering types) and runtime (processing data). Called in order, and their effects combine.

```ruby
capability Capability::Filtering
capability Capability::Pagination
```

## Next Steps

- [Serializers](./serializers.md) - Transform records to response data
- [Wrappers](./wrappers.md) - Structure response bodies
- [Capabilities](./capabilities/introduction.md) - Self-contained features
- [Organizing](./organizing.md) - File structure conventions

#### See also

- [Adapter::Base reference](/reference/adapter-base)
- [Standard Adapter](../standard-adapter/introduction.md)
