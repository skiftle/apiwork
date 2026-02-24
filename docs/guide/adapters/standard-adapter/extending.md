---
order: 10
---

# Extending

The standard adapter can be subclassed for minor modifications without building a full custom adapter.

## Skipping Capabilities

`skip_capability` disables built-in capabilities:

```ruby
class MinimalAdapter < Apiwork::Adapter::Standard
  adapter_name :minimal

  skip_capability :sorting
  skip_capability :filtering
  skip_capability :including
end
```

## Replacing Components

Individual components can be replaced while keeping the rest:

```ruby
class CustomAdapter < Apiwork::Adapter::Standard
  adapter_name :custom

  collection_wrapper CustomCollectionWrapper
  error_serializer CustomErrorSerializer
end
```

## When to Use Custom Adapters

For larger changes, create a [custom adapter](../custom-adapters/) instead:

- Different response format (JSON:API, HAL)
- Custom pagination strategy
- Modified filtering logic
- Different serialization behavior

#### See also

- [Custom Adapters](../custom-adapters/) — building a full custom adapter
- [Capabilities](../custom-adapters/capabilities/) — capability architecture
