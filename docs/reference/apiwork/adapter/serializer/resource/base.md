---
order: 26
prev: false
next: false
---

# Base

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L44)

The contract builder for this serializer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Builder::Contract::Base>`, `nil` | `nil` | The builder class. |

</div>

**Returns**

Class&lt;[Builder::Contract::Base](/reference/apiwork/adapter/builder/contract/base)&gt;, `nil`

---

### .data_type

`.data_type(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L33)

The data type for this serializer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `block` | `Proc`, `nil` | `nil` | Block that receives representation_class and returns type name. |

</div>

**Returns**

`Proc`, `nil`

---

## Instance Methods

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L54)

The representation class for this serializer.

**Returns**

Class&lt;[Representation::Base](/reference/apiwork/representation/base)&gt;

---

### #serialize

`#serialize(resource, context:, serialize_options:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/base.rb#L77)

Serializes a resource.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`resource`** | `Object` |  | The resource to serialize. |
| **`context`** | `Hash` |  | The serialization context. |
| **`serialize_options`** | `Hash` |  | The options (e.g., include). |

</div>

**Returns**

`Hash`

---
