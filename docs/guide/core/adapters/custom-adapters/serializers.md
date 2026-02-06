---
order: 2
---

# Serializers

Serializers convert records and errors to response data. An adapter uses two serializer types:

- **Resource serializer** - converts records and collections
- **Error serializer** - converts [errors](../../errors/introduction.md) (contract, domain, HTTP)

## Resource Serializers

Resource serializers inherit from [`Adapter::Serializer::Resource::Base`](/reference/adapter/serializer/resource/base):

```ruby
class MyResourceSerializer < Adapter::Serializer::Resource::Base
  data_type { |representation_class| representation_class.singular_key_name }
  contract_builder ContractBuilder

  def serialize(resource, context:, serialize_options:)
    representation_class.serialize(resource, context:)
  end
end
```

### DSL Methods

#### data_type

A block that receives the representation class and returns the type name used in responses. This type name is referenced by wrappers when building response shapes.

```ruby
data_type { |representation_class| representation_class.singular_key_name }
```

#### contract_builder

The class that registers contract-level types for this serializer. Called during introspection for each contract-representation pair.

```ruby
contract_builder ContractBuilder
```

### Instance Methods

#### serialize

Override to implement serialization logic:

```ruby
def serialize(resource, context:, serialize_options:)
  # resource: single record or collection
  # context: passed from controller
  # serialize_options: from capabilities (e.g., includes)
  representation_class.serialize(resource, context:)
end
```

The `representation_class` attribute provides access to the representation class.

## Error Serializers

Error serializers inherit from [`Adapter::Serializer::Error::Base`](/reference/adapter/serializer/error/base):

```ruby
class MyErrorSerializer < Adapter::Serializer::Error::Base
  data_type :error
  api_builder APIBuilder

  def serialize(error, context:)
    { errors: error.issues.map(&:to_h) }
  end
end
```

### DSL Methods

#### data_type

A symbol naming the error type. Referenced by error wrappers.

```ruby
data_type :error
```

#### api_builder

The class that registers API-level error types. Called once per API during introspection.

```ruby
api_builder APIBuilder
```

### Instance Methods

#### serialize

Override to implement error serialization:

```ruby
def serialize(error, context:)
  # error: the error object with issues
  # context: passed from controller
  { errors: error.issues.map(&:to_h) }
end
```

## Contract Builder Example

Resource serializers typically register the resource type via a contract builder:

```ruby
class ContractBuilder < Adapter::Builder::Contract::Base
  def build
    object(representation_class.singular_key_name) do |object|
      representation_class.attributes.each_value do |attribute|
        object.public_send(attribute.type, attribute.name)
      end
    end
  end
end
```

## API Builder Example

Error serializers typically register error types via an API builder:

```ruby
class APIBuilder < Adapter::Builder::API::Base
  def build
    object(:error) do |object|
      object.string(:code)
      object.string(:message)
      object.string?(:field)
    end
  end
end
```

## Using Custom Serializers

Register custom serializers in your adapter:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  adapter_name :my

  resource_serializer MyResourceSerializer
  error_serializer MyErrorSerializer
end
```

#### See also

- [Serializer::Resource::Base reference](/reference/adapter/serializer/resource/base)
- [Serializer::Error::Base reference](/reference/adapter/serializer/error/base)
- [Error Handling](../../errors/introduction.md)
- [Wrappers](./wrappers.md)
