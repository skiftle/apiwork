---
order: 3
---

# Wrappers

Wrappers structure the final response body. An adapter uses three wrapper types:

- **Member wrapper** - structures single-record responses (show, create, update)
- **Collection wrapper** - structures multi-record responses (index)
- **Error wrapper** - structures error responses

Each wrapper has two responsibilities:

1. **Shape** - defines the response structure for introspection
2. **Wrap** - transforms data into the final response format

## Member Wrappers

Member wrappers inherit from [`Adapter::Wrapper::Member::Base`](/reference/adapter-wrapper-member-base):

```ruby
class MyMemberWrapper < Adapter::Wrapper::Member::Base
  shape do
    reference(root_key.singular.to_sym, to: data_type)
    object?(:meta)
    merge_shape!(metadata_shapes)
  end

  def wrap
    {
      root_key.singular.to_sym => data,
      meta: meta.presence,
      **metadata,
    }.compact
  end
end
```

### Available Attributes

| Attribute | Description |
|-----------|-------------|
| `data` | The serialized record |
| `root_key` | Access to singular/plural key names |
| `meta` | Custom metadata from controller |
| `metadata` | Capability metadata (includes, etc.) |

## Collection Wrappers

Collection wrappers inherit from [`Adapter::Wrapper::Collection::Base`](/reference/adapter-wrapper-collection-base):

```ruby
class MyCollectionWrapper < Adapter::Wrapper::Collection::Base
  shape do
    array(root_key.plural.to_sym) do |array|
      array.reference(data_type)
    end
    object?(:meta)
    merge_shape!(metadata_shapes)
  end

  def wrap
    {
      root_key.plural.to_sym => data,
      meta: meta.presence,
      **metadata,
    }.compact
  end
end
```

### Available Attributes

Same as member wrappers, plus:

| Attribute | Description |
|-----------|-------------|
| `data` | Array of serialized records |
| `metadata` | Capability metadata (pagination, etc.) |

## Error Wrappers

Error wrappers inherit from [`Adapter::Wrapper::Error::Base`](/reference/adapter-wrapper-error-base):

```ruby
class MyErrorWrapper < Adapter::Wrapper::Error::Base
  shape do
    extends(data_type)
  end

  def wrap
    data
  end
end
```

## The Shape DSL

The `shape` block defines the response type structure for introspection. Inside the block:

### Available Methods

All [type DSL methods](../../types/objects.md) from `API::Object`:

| Method | Purpose |
|--------|---------|
| `string`, `string?` | String field (required/optional) |
| `integer`, `integer?` | Integer field |
| `boolean`, `boolean?` | Boolean field |
| `object`, `object?` | Nested object |
| `array`, `array?` | Array field |
| `reference`, `reference?` | Reference to another type |
| `extends` | Inherit from another type |
| `merge_shape!` | Merge fields from another shape |

### Available Helpers

| Helper | Description |
|--------|-------------|
| `root_key` | Resource root key (has `.singular` and `.plural`) |
| `data_type` | Type name from serializer |
| `metadata_shapes` | Aggregated shapes from [capability operations](./capabilities/operations.md) |

### merge_shape!

The `merge_shape!(metadata_shapes)` call merges fields from all capability operations that define a [`metadata_shape`](./capabilities/operations.md#metadata_shape). This is how pagination, filtering metadata, etc. appear in the response type.

## Example: JSON:API Wrapper

```ruby
class JsonApiMemberWrapper < Adapter::Wrapper::Member::Base
  shape do
    object(:data) do |object|
      object.string(:type)
      object.string(:id)
      object.reference(:attributes, to: data_type)
    end
  end

  def wrap
    {
      data: {
        type: root_key.singular,
        id: data[:id].to_s,
        attributes: data.except(:id)
      }
    }
  end
end
```

## Example: Envelope Wrapper

```ruby
class EnvelopeMemberWrapper < Adapter::Wrapper::Member::Base
  shape do
    literal(:success, value: true)
    reference(:data, to: data_type)
    object?(:meta)
    merge_shape!(metadata_shapes)
  end

  def wrap
    {
      success: true,
      data: data,
      meta: meta.presence,
      **metadata,
    }.compact
  end
end
```

## Using Custom Wrappers

Register custom wrappers in your adapter:

```ruby
class MyAdapter < Apiwork::Adapter::Base
  adapter_name :my

  member_wrapper MyMemberWrapper
  collection_wrapper MyCollectionWrapper
  error_wrapper MyErrorWrapper
end
```

#### See also

- [Wrapper::Member::Base reference](/reference/adapter-wrapper-member-base)
- [Wrapper::Collection::Base reference](/reference/adapter-wrapper-collection-base)
- [Wrapper::Error::Base reference](/reference/adapter-wrapper-error-base)
- [Operations - metadata_shape](./capabilities/operations.md)
