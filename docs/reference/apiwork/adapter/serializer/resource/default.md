---
order: 27
prev: false
next: false
---

# Default

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/resource/default.rb#L23)

Default resource serializer.

Delegates serialization to the representation class using its root key as data type.

**Example: Configuration**

```ruby
class MyAdapter < Adapter::Base
  serializer Serializer::Resource::Default
end
```

**Example: Output**

```ruby
{
  "id": 1,
  "number": "INV-001",
  "customer": { "id": 5, "name": "Acme" }
}
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
