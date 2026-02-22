---
order: 5
---

# Operations

Operations run at request time to process data. They filter, sort, paginate, or otherwise transform the data before serialization. Operations inherit from [`Adapter::Capability::Operation::Base`](/reference/adapter/capability/operation/base).

```ruby
class Operation < Adapter::Capability::Operation::Base
  target :collection

  metadata_shape do
    reference(:pagination, to: :offset_pagination)
  end

  def apply
    paginated = paginate(data)
    result(data: paginated, metadata: { pagination: pagination_info })
  end
end
```

## Operation DSL

### target

Restricts the operation to a specific response type:

```ruby
target :collection  # Only runs for index/collection actions
target :member      # Only runs for show/create/update actions
```

Omit `target` to run for both collection and member responses.

### metadata_shape

Defines metadata fields added to the response. This is critical for introspection — it tells the type system what shape the metadata will have. Each `metadata_shape` is registered as a [fragment](/guide/types/type-reuse.md#fragments) type. Wrappers use [`metadata_type_names`](../wrappers.md#metadata_type_names) to merge these fields into response types.

```ruby
metadata_shape do
  reference(:pagination, to: :offset_pagination)
end

# Or with a class
metadata_shape PaginationMetadataShape
```

Inside the block, use type DSL methods (`integer`, `string`, `object`, `reference`, etc.) to define the shape. Access `options` to read capability configuration.

### apply

Override this method to implement the operation logic. Return `nil` for no changes, or use `result` to return transformed data.

```ruby
def apply
  filtered = filter(data)
  result(data: filtered)
end
```

### result

Creates a result object with transformed data and optional metadata:

```ruby
result(
  data: transformed_data,           # Transformed data (relation or record)
  metadata: { pagination: info },   # Metadata added to response
  includes: [:customer, :lines],    # Associations to preload
  serialize_options: { ... }        # Options passed to serializer
)
```

## Available Attributes

Inside an operation, these attributes are available:

| Attribute | Description |
|-----------|-------------|
| `data` | The data to transform (relation or record) |
| `options` | Capability configuration |
| `request` | The current request |
| `representation_class` | The representation class for this request |

## translate

Translates a key using the adapter's i18n convention:

```ruby
translate(:errors, :invalid_filter, default: "Invalid filter")
```

Lookup order:
1. `apiwork.apis.<locale_key>.adapters.<adapter_name>.capabilities.<capability_name>.<key>`
2. `apiwork.adapters.<adapter_name>.capabilities.<capability_name>.<key>`
3. Provided default

## Example: Simple Counter

A capability that counts records and adds the count to metadata:

```ruby
class Counting < Adapter::Capability::Base
  capability_name :counting

  operation do
    target :collection

    metadata_shape do
      integer(:total_count)
    end

    def apply
      count = data.count
      result(metadata: { total_count: count })
    end
  end
end
```

## Example: Pagination Operation

```ruby
class Operation < Adapter::Capability::Operation::Base
  target :collection

  metadata_shape do
    reference(:pagination, to: options.strategy == :cursor ? :cursor_pagination : :offset_pagination)
  end

  def apply
    page_number = request.params.dig(:page, :number) || 1
    page_size = [request.params.dig(:page, :size) || options.default_size, options.max_size].min

    paginated = data.offset((page_number - 1) * page_size).limit(page_size)
    total = data.count

    result(
      data: paginated,
      metadata: {
        pagination: {
          current_page: page_number,
          per_page: page_size,
          total_pages: (total.to_f / page_size).ceil,
          total_count: total
        }
      }
    )
  end
end
```

## MetadataShape Class

For complex shapes, create a separate class inheriting from [`Adapter::Capability::Operation::MetadataShape`](/reference/adapter/capability/operation/metadata-shape):

```ruby
class PaginationMetadataShape < Adapter::Capability::Operation::MetadataShape
  def apply
    if options.strategy == :cursor
      reference(:pagination, to: :cursor_pagination)
    else
      reference(:pagination, to: :offset_pagination)
    end
  end
end
```

The `options` attribute provides access to capability configuration.

#### See also

- [Capability::Operation::Base reference](/reference/adapter/capability/operation/base)
- [Capability::Operation::MetadataShape reference](/reference/adapter/capability/operation/metadata-shape)
- [Wrappers](../wrappers.md)
