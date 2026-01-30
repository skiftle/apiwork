---
order: 16
prev: false
next: false
---

# Adapter::Capability::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/shape.rb#L17)

Shape builder for capability metadata.

Provides [#options](#options) for accessing capability configuration,
plus all DSL methods from [API::Object](api-object) for defining structure.
Used by computations to define their metadata contribution.

**Example: Add pagination metadata**

```ruby
metadata do |shape|
  shape.reference :pagination
end
```

## Instance Methods

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/shape.rb#L20)

**Returns**

[Configuration](configuration) — capability options

---
