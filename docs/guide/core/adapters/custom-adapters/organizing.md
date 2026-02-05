---
order: 5
---

# Organizing

Custom adapters can involve many files. Consider following this file structure:

## File Structure

```
json_api.rb
json_api/
├── capability/
│   ├── filtering.rb
│   └── filtering/
│       ├── api_builder.rb
│       ├── contract_builder.rb
│       ├── operation.rb
│       └── request_transformer.rb
├── serializer/
│   ├── resource.rb
│   ├── resource/
│   │   └── contract_builder.rb
│   ├── error.rb
│   └── error/
│       └── api_builder.rb
└── wrapper/
    ├── member.rb
    ├── collection.rb
    └── error.rb
```

## Naming Conventions

| Component | Class Name | File Path |
|-----------|------------|-----------|
| Adapter | `JsonApi` | `json_api.rb` |
| Resource serializer | `Serializer::Resource` | `serializer/resource.rb` |
| Error serializer | `Serializer::Error` | `serializer/error.rb` |
| Member wrapper | `Wrapper::Member` | `wrapper/member.rb` |
| Collection wrapper | `Wrapper::Collection` | `wrapper/collection.rb` |
| Error wrapper | `Wrapper::Error` | `wrapper/error.rb` |
| Capability | `Capability::Filtering` | `capability/filtering.rb` |
| API builder | `Capability::Filtering::APIBuilder` | `capability/filtering/api_builder.rb` |
| Contract builder | `Capability::Filtering::ContractBuilder` | `capability/filtering/contract_builder.rb` |
| Operation | `Capability::Filtering::Operation` | `capability/filtering/operation.rb` |
| Request transformer | `Capability::Filtering::RequestTransformer` | `capability/filtering/request_transformer.rb` |

## Adapter Definition

The main adapter file assembles all components:

```ruby
class JsonApi < Apiwork::Adapter::Base
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

## Capability Definition

Capability definitions declare components:

```ruby
class Filtering < Apiwork::Adapter::Capability::Base
  capability_name :filtering

  option :operators, type: :hash do
    option :string, type: :symbol, default: :all, enum: %i[all basic]
  end

  request_transformer RequestTransformer
  api_builder APIBuilder
  contract_builder ContractBuilder
  operation Operation
end
```

## Registration

Register your adapter in an initializer:

```ruby
Apiwork::Adapter.register(JsonApi)
```

## Using the Adapter

Reference by name in [API definitions](../../api-definitions/configuration.md#adapter):

```ruby
Apiwork::API.define '/api/v1' do
  adapter :json_api
end
```

#### See also

- [API Definitions](../../api-definitions/introduction.md)
- [Adapter Configuration](../../api-definitions/configuration.md#adapter)
