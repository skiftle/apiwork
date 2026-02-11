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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L44)

The API builder for this serializer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Builder::API::Base>`, `nil` | `nil` | The builder class. |

</div>

**Returns**

Class&lt;[Builder::API::Base](/reference/adapter/builder/api/base)&gt;, `nil`

---

### .data_type

`.data_type(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L33)

The data type for this serializer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol`, `nil` | `nil` | The type name. |

</div>

**Returns**

`Symbol`, `nil`

---

## Instance Methods

### #serialize

`#serialize(error, context:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/serializer/error/base.rb#L65)

Serializes an error.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`error`** | `Error` |  | The error to serialize. |
| **`context`** | `Hash` |  | The serialization context. |

</div>

**Returns**

`Hash`

---
