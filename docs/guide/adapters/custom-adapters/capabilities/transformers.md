---
order: 3
---

# Transformers

Transformers modify requests and responses as they flow through the adapter. Capabilities can register:

- **Request transformers** - modify incoming data before or after validation
- **Response transformers** - modify outgoing data before it's sent

## Request Transformers

Request transformers inherit from [`Adapter::Capability::Transformer::Request::Base`](/reference/adapter/capability/transformer/request/base):

```ruby
class MyRequestTransformer < Adapter::Capability::Transformer::Request::Base
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

### phase

Configures when the transformer runs relative to request validation:

| Phase | Description |
|-------|-------------|
| `:before` | Runs on raw input before validation (default) |
| `:after` | Runs on validated data after validation |

```ruby
phase :before  # Transform raw input
phase :after   # Transform validated data
```

### transform

The `transform` method implements transformation logic. `request.transform` to modify the request data:

```ruby
def transform
  request.transform { |data| modify(data) }
end
```

For body-specific transformations:

```ruby
def transform
  request.transform_body { |body| modify(body) }
end
```

### Registering Request Transformers

In the capability:

```ruby
class MyCapability < Adapter::Capability::Base
  request_transformer MyRequestTransformer
end
```

## Response Transformers

Response transformers inherit from [`Adapter::Capability::Transformer::Response::Base`](/reference/adapter/capability/transformer/response/base):

```ruby
class MyResponseTransformer < Adapter::Capability::Transformer::Response::Base
  def transform
    response.transform_body { |body| body.merge(generated_at: Time.zone.now) }
  end
end
```

### transform

Override to implement transformation logic. Use `response.transform_body` to modify the response:

```ruby
def transform
  response.transform_body { |body| modify(body) }
end
```

### Registering Response Transformers

In the capability:

```ruby
class MyCapability < Adapter::Capability::Base
  response_transformer MyResponseTransformer
end
```

## Example: Indexed Hash to Array

The standard filtering capability transforms indexed hashes (from form data) to arrays:

```ruby
class RequestTransformer < Adapter::Capability::Transformer::Request::Base
  NUMERIC_KEY_PATTERN = /^\d+$/

  phase :before

  def transform
    request.transform(&method(:process))
  end

  private

  def process(value)
    case value
    when Hash then apply(value)
    when Array then value.map(&method(:process))
    else value
    end
  end

  def apply(hash)
    return to_array(hash) if indexed_hash?(hash)

    hash.transform_values(&method(:process))
  end

  def to_array(hash)
    hash.keys.sort_by { |key| key.to_s.to_i }.map { |key| process(hash[key]) }
  end

  def indexed_hash?(hash)
    return false if hash.empty?

    hash.keys.all? { |key| NUMERIC_KEY_PATTERN.match?(key.to_s) }
  end
end
```

Input: `{ "0" => "a", "1" => "b" }`
Output: `["a", "b"]`

## Example: Writing Transformer

The standard writing capability transforms operation markers after validation. This converts `OP: 'delete'` to `_destroy: true` for Rails `accepts_nested_attributes_for`:

```ruby
class RequestTransformer < Adapter::Capability::Transformer::Request::Base
  phase :after

  def transform
    request.transform_body(&method(:process))
  end

  private

  def process(value)
    case value
    when Hash then apply(value.transform_values(&method(:process)))
    when Array then value.map(&method(:process))
    else value
    end
  end

  def apply(hash)
    return hash unless hash.key?(Constants::OP)

    result = hash.except(Constants::OP)
    result[:_destroy] = true if hash[Constants::OP] == 'delete'
    result
  end
end
```

Converts `{ OP: 'delete', id: 1 }` to `{ id: 1, _destroy: true }` for Rails `accepts_nested_attributes_for`.

#### See also

- [Transformer::Request::Base reference](/reference/adapter/capability/transformer/request/base)
- [Transformer::Response::Base reference](/reference/adapter/capability/transformer/response/base)
