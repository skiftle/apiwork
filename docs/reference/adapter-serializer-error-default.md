---
order: 21
prev: false
next: false
---

# Adapter::Serializer::Error::Default

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/default.rb#L22)

Default error serializer.

Serializes errors into a hash with issues array and layer.

**Example: Configuration**

```ruby
class MyAdapter < Adapter::Base
  error_serializer Serializer::Error::Default
end
```

**Example: Output**

```ruby
{
  "issues": [{ "code": "invalid", "detail": "...", "path": [...], "pointer": "/..." }],
  "layer": "contract"
}
```

## Class Methods

### .api_builder

`.api_builder(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L38)

Sets or gets the API type builder class.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class, nil` | a Builder::API::Base subclass |

**Returns**

`Class`, `nil`

---

### .data_type

`.data_type(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L28)

Sets or gets the data type name for this serializer.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the type name |

**Returns**

`Symbol`, `nil`

---
