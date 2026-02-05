---
order: 1
---

# Introduction

An adapter is the engine of an API. It handles both introspection (generating types from representations) and runtime (processing requests through capabilities, serializing, and wrapping responses). Custom adapters inherit from [`Apiwork::Adapter::Base`](/reference/adapter-base).

The adapter class declaration acts as a manifest that assembles components:

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

## Components

An adapter combines five types of components:

| Component | Purpose |
|-----------|---------|
| Resource serializer | Converts records to response data |
| Error serializer | Converts errors to response data |
| Member wrapper | Structures single-record responses |
| Collection wrapper | Structures multi-record responses |
| Error wrapper | Structures error responses |
| Capabilities | Self-contained features (filtering, pagination, etc.) |

## Two Phases

Adapters operate in two distinct phases:

### Introspection Phase

Runs once when the API loads. Components register types based on representations:

- **Capabilities** register their types (filter schemas, sort schemas, pagination schemas)
- **Serializers** register resource and error types
- **Wrappers** define response shapes

### Runtime Phase

Runs for every request. The adapter processes data through its pipeline:

1. **Transform request** - Capabilities modify incoming data
2. **Apply capabilities** - Filter, sort, paginate the data
3. **Serialize** - Convert records to hashes
4. **Wrap response** - Structure the response body
5. **Transform response** - Capabilities modify outgoing data

## Adapter DSL

### adapter_name

The identifier used to reference this adapter. Required for registration with `Apiwork::Adapter.register`. Used as the key when selecting adapters in API definitions (`adapter :my`) and in i18n translation paths (`apiwork.adapters.my.capabilities...`).

```ruby
adapter_name :my
```

### resource_serializer

The class that converts records and collections to response data. Called with the representation class and returns serialized hashes. Also responsible for registering the resource type at introspection time.

```ruby
resource_serializer Serializer::Resource::Default
```

### error_serializer

The class that converts errors to response data. Called for contract errors (validation), domain errors (business logic), and HTTP errors. Also responsible for registering the error type at introspection time.

```ruby
error_serializer Serializer::Error::Default
```

### member_wrapper

The class that structures single-record responses (show, create, update). Takes serialized data and wraps it in the final response format. Defines the response shape through its `shape` class method.

```ruby
member_wrapper Wrapper::Member::Default
```

### collection_wrapper

The class that structures multi-record responses (index, collection actions). Takes serialized data and metadata (pagination, etc.) and wraps them in the final response format.

```ruby
collection_wrapper Wrapper::Collection::Default
```

### error_wrapper

The class that structures error responses. Takes serialized error data and wraps it in the final response format.

```ruby
error_wrapper Wrapper::Error::Default
```

### capability

Registers a capability. Capabilities contribute to both introspection (registering types) and runtime (processing data). Called in order, and their effects combine.

```ruby
capability Capability::Filtering
capability Capability::Pagination
```

### skip_capability

Removes an inherited capability by its `capability_name`. Use when subclassing an adapter to disable features.

```ruby
class MinimalAdapter < Apiwork::Adapter::Standard
  skip_capability :sorting
  skip_capability :including
end
```

## When to Create a Custom Adapter

Create a custom adapter when you need to:

- Change the response format (JSON:API, HAL, custom structure)
- Implement different pagination strategies
- Add custom filtering logic
- Modify serialization behavior
- Support different client requirements

Most customizations can be achieved by:

1. Creating custom serializers
2. Creating custom wrappers
3. Creating or modifying capabilities
4. Subclassing the standard adapter and replacing components

## The Standard Adapter

The [standard adapter](../standard-adapter/introduction.md) serves as a reference implementation:

```ruby
class Standard < Base
  adapter_name :standard

  resource_serializer Serializer::Resource::Default
  error_serializer Serializer::Error::Default

  member_wrapper Wrapper::Member::Default
  collection_wrapper Wrapper::Collection::Default
  error_wrapper Wrapper::Error::Default

  capability Capability::Filtering
  capability Capability::Including
  capability Capability::Pagination
  capability Capability::Sorting
  capability Capability::Writing
end
```

Study its components to understand how the pieces fit together.

## Next Steps

- [Serializers](./serializers.md) - Transform records to response data
- [Wrappers](./wrappers.md) - Structure response bodies
- [Capabilities](./capabilities/introduction.md) - Self-contained features
- [Organizing](./organizing.md) - File structure conventions

#### See also

- [Adapter::Base reference](/reference/adapter-base)
- [Standard Adapter](../standard-adapter/introduction.md)
