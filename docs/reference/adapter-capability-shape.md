---
order: 15
prev: false
next: false
---

# Adapter::Capability::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/shape.rb#L16)

Shape builder for capability response shapes.

Provides [#options](#options) for accessing capability configuration,
plus all DSL methods from [API::Object](api-object) for defining response structure.

**Example**

```ruby
shape do |shape|
  shape.reference(:pagination, to: shape.options.strategy == :cursor ? :cursor_pagination : :offset_pagination)
end
```

## Instance Methods

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/shape.rb#L19)

**Returns**

[Configuration](configuration) — capability options

---
