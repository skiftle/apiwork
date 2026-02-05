---
order: 25
prev: false
next: false
---

# Adapter::Transformer::Request::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/request/base.rb#L35)

Base class for request transformers.

Request transformers modify requests before or after validation.
Register transformers in capabilities using [Adapter::Capability::Base.request_transformer](adapter-capability-base#request-transformer).

**Example: Strip whitespace from strings**

```ruby
class MyRequestTransformer < Transformer::Request::Base
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/request/base.rb#L44)

Configures when this transformer runs relative to request validation. Defaults to :before.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | :before runs on raw input, :after runs on validated data |

**Returns**

`Symbol` — the phase

---

## Instance Methods

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/request/base.rb#L62)

Transforms the request.

**Returns**

[Request](request) — the transformed request

---
