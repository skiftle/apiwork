---
order: 25
prev: false
next: false
---

# Default

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L42)

The API builder for this serializer.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Builder::API::Base>`, `nil` |  | the builder class |

**Returns**

Class&lt;[Builder::API::Base](/reference/adapter/builder/api/base)&gt;, `nil`

---

### .data_type

`.data_type(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L32)

The data type for this serializer.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol`, `nil` |  | the type name |

**Returns**

`Symbol`, `nil`

---
