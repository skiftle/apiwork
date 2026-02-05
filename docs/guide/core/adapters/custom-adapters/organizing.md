---
order: 5
---

# Organizing

Follow the [standard adapter's](../standard-adapter/introduction.md) file structure as a reference when building custom adapters.

## File Structure

A well-organized adapter follows this structure:

```
lib/my_app/adapter/
├── json_api.rb                      # Adapter definition
└── json_api/
    ├── serializer/
    │   ├── resource/
    │   │   ├── default.rb           # Resource serializer
    │   │   └── default/
    │   │       └── contract_builder.rb
    │   └── error/
    │       ├── default.rb           # Error serializer
    │       └── default/
    │           └── api_builder.rb
    ├── wrapper/
    │   ├── member/
    │   │   └── default.rb           # Member wrapper
    │   ├── collection/
    │   │   └── default.rb           # Collection wrapper
    │   └── error/
    │       └── default.rb           # Error wrapper
    └── capability/
        ├── filtering.rb             # Capability definition
        └── filtering/
            ├── api_builder.rb
            ├── contract_builder.rb
            ├── operation.rb
            └── request_transformer.rb
```

## Naming Conventions

| Component | Class Name | File Path |
|-----------|------------|-----------|
| Adapter | `JsonApi` | `json_api.rb` |
| Resource serializer | `Serializer::Resource::Default` | `serializer/resource/default.rb` |
| Error serializer | `Serializer::Error::Default` | `serializer/error/default.rb` |
| Member wrapper | `Wrapper::Member::Default` | `wrapper/member/default.rb` |
| Collection wrapper | `Wrapper::Collection::Default` | `wrapper/collection/default.rb` |
| Error wrapper | `Wrapper::Error::Default` | `wrapper/error/default.rb` |
| Capability | `Capability::Filtering` | `capability/filtering.rb` |
| API builder | `Capability::Filtering::APIBuilder` | `capability/filtering/api_builder.rb` |
| Contract builder | `Capability::Filtering::ContractBuilder` | `capability/filtering/contract_builder.rb` |
| Operation | `Capability::Filtering::Operation` | `capability/filtering/operation.rb` |
| Request transformer | `Capability::Filtering::RequestTransformer` | `capability/filtering/request_transformer.rb` |

## Adapter Definition

The main adapter file assembles all components:

```ruby
# lib/my_app/adapter/json_api.rb
module MyApp
  module Adapter
    class JsonApi < Apiwork::Adapter::Base
      adapter_name :json_api

      resource_serializer Serializer::Resource::Default
      error_serializer Serializer::Error::Default

      member_wrapper Wrapper::Member::Default
      collection_wrapper Wrapper::Collection::Default
      error_wrapper Wrapper::Error::Default

      capability Capability::Filtering
      capability Capability::Pagination
    end
  end
end
```

## Capability Definition

Keep capability definitions minimal - they declare components:

```ruby
# lib/my_app/adapter/json_api/capability/filtering.rb
module MyApp
  module Adapter
    class JsonApi
      module Capability
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
      end
    end
  end
end
```

## Registration

Register your adapter in an initializer:

```ruby
# config/initializers/apiwork.rb
require 'my_app/adapter/json_api'

Apiwork::Adapter.register(MyApp::Adapter::JsonApi)
```

## Using the Adapter

Reference by name in [API definitions](../../api-definitions/configuration.md#adapter):

```ruby
Apiwork::API.define '/api/v1' do
  adapter :json_api
end
```

## Subclassing Standard

For minor modifications, subclass the [standard adapter](../standard-adapter/introduction.md):

```ruby
class CustomAdapter < Apiwork::Adapter::Standard
  adapter_name :custom

  # Replace one component
  collection_wrapper CustomCollectionWrapper

  # Skip capabilities
  skip_capability :sorting
end
```

#### See also

- [Standard Adapter](../standard-adapter/introduction.md)
- [API Definitions](../../api-definitions/introduction.md)
- [Adapter Configuration](../../api-definitions/configuration.md#adapter)
