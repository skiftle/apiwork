---
order: 23
prev: false
next: false
---

# Adapter::Serializer::Resource::Default

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
