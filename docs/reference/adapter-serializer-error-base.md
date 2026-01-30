---
order: 19
prev: false
next: false
---

# Adapter::Serializer::Error::Base

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

## Instance Methods

### #serialize

`#serialize(error, context:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L57)

Serializes an error.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error` | `Error` | the error to serialize |
| `context` | `Hash` | serialization context |

**Returns**

`Hash` — the serialized error

---
