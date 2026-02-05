---
order: 22
prev: false
next: false
---

# Adapter::Serializer::Resource::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L21)

Base class for resource serializers.

Resource serializers handle serialization of records and collections
and define resource types at the contract level.

**Example**

```ruby
class MyResourceSerializer < Serializer::Resource::Base
  contract_builder Builder::Contract

  def serialize(resource, context:, serialize_options:)
    representation_class.serialize(resource, context:)
  end
end
```

## Class Methods

### .contract_builder

`.contract_builder(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L42)

Sets or gets the Contract type builder class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class, nil` | a Builder::Contract::Base subclass |

**Returns**

`Class`, `nil`

---

### .data_type

`.data_type(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L32)

Sets or gets the data type resolver for this serializer.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `block` | `Proc, nil` | block that receives representation_class and returns type name |

**Returns**

`Proc`, `nil`

---

## Instance Methods

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L50)

**Returns**

`Class` — the representation class

---

### #serialize

`#serialize(resource, context:, serialize_options:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L70)

Serializes a resource.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `resource` | `Object` | the resource to serialize |
| `context` | `Hash` | serialization context |
| `serialize_options` | `Hash` | options (e.g., include) |

**Returns**

`Hash` — the serialized resource

---
