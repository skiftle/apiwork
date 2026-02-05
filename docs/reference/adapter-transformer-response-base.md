---
order: 26
prev: false
next: false
---

# Adapter::Transformer::Response::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/response/base.rb#L19)

Base class for response transformers.

Response transformers modify responses before they are returned.
Register transformers in capabilities using [Adapter::Capability::Base.response_transformer](adapter-capability-base#response-transformer).

**Example: Add generated_at to response**

```ruby
class MyResponseTransformer < Transformer::Response::Base
  def transform
    response.transform_body { |body| body.merge(generated_at: Time.zone.now) }
  end
end
```

## Instance Methods

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/response/base.rb#L36)

Transforms the response.

**Returns**

[Response](response) — the transformed response

---
