---
order: 24
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L21)

Base class for error serializers.

Error serializers handle serialization of errors and define
error-related types at the API level.

**Example**

```ruby
class MyErrorSerializer < Serializer::Error::Base
  api_builder Builder::API

  def serialize(error, context:)
    { errors: error.issues.map(&:to_h) }
  end
end
```

## Class Methods

### .api_builder

`.api_builder(klass = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L42)

The API builder for this serializer.

**Parameters**

| Name | Type | Description |
|------|------|------|
| `klass` | `Class<Builder::API::Base>, nil` | the builder class |

**Returns**

Class&lt;[Builder::API::Base](/reference/adapter/builder/api/base)&gt;, `nil`

---

### .data_type

`.data_type(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L32)

The data type for this serializer.

**Parameters**

| Name | Type | Description |
|------|------|------|
| `name` | `Symbol, nil` | the type name |

**Returns**

`Symbol`, `nil`

---

## Instance Methods

### #serialize

`#serialize(error, context:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L61)

Serializes an error.

**Parameters**

| Name | Type | Description |
|------|------|------|
| `error` | `Error` | the error to serialize |
| `context` | `Hash` | serialization context |

**Returns**

`Hash`

---
