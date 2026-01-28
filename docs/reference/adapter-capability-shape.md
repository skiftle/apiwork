---
order: 15
prev: false
next: false
---

# Adapter::Capability::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/shape.rb#L17)

Shape builder for capability response shapes.

Extends the document shape with capability-specific fields.
Provides [#options](#options) for accessing capability configuration,
plus all DSL methods from [API::Object](api-object) for defining structure.

**Example: Add pagination to response**

```ruby
shape do |shape|
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
