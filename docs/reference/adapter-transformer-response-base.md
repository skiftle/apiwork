---
order: 25
prev: false
next: false
---

# Adapter::Transformer::Response::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/response/base.rb#L21)

Base class for response transformers.

Response transformers modify responses before they are returned.
Register transformers in capabilities using [Capability::Base.response_transformer](capability-base#response-transformer).

**Example: Custom response transformer**

```ruby
class AddTimestamp < Transformer::Response::Base
  def transform
    response.transform do |body|
      body.merge(timestamp: Time.current.iso8601)
    end
  end
end
```

## Instance Methods

### #transform

`#transform`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/transformer/response/base.rb#L38)

Transforms the response.

**Returns**

`Apiwork::Response` — the transformed response

---
