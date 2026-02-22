---
order: 22
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/transformer/request/base.rb#L36)

Base class for request transformers.

Request transformers modify requests before or after validation.
Register transformers in capabilities using [Capability::Base.request_transformer](/reference/apiwork/adapter/capability/base#request-transformer).

**Example: Strip whitespace from strings**

```ruby
class MyRequestTransformer < Capability::Transformer::Request::Base
  phase :before

  def transform
    request.transform { |data| strip_strings(data) }
  end

  private

  def strip_strings(value)
    case value
    when String then value.strip
    when Hash then value.transform_values { |v| strip_strings(v) }
    when Array then value.map { |v| strip_strings(v) }
    else value
    end
  end
end
```

## Class Methods

### .phase

`.phase(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/transformer/request/base.rb#L46)

The phase for this transformer.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Symbol<:after, :before>`, `nil` | `nil` | The phase. Defaults to `:before` when not set. |

</div>

**Returns**

`Symbol`

---

## Instance Methods

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/transformer/request/base.rb#L64)

Transforms the request.

**Returns**

[Request](/reference/request)

---
