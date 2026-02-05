---
order: 8
---

# Extending

Subclass the standard adapter for minor modifications without building a full custom adapter.

## Skipping Capabilities

Use `skip_capability` to disable built-in capabilities:

```ruby
class MinimalAdapter < Apiwork::Adapter::Standard
  adapter_name :minimal

  skip_capability :sorting
  skip_capability :filtering
  skip_capability :including
end
```

## Replacing Components

Replace individual components while keeping the rest:

```ruby
class CustomAdapter < Apiwork::Adapter::Standard
  adapter_name :custom

  collection_wrapper CustomCollectionWrapper
  error_serializer CustomErrorSerializer
end
```

## When to Use Custom Adapters

For larger changes, create a [custom adapter](../custom-adapters/introduction.md) instead:

- Different response format (JSON:API, HAL)
- Custom pagination strategy
- Modified filtering logic
- Different serialization behavior
