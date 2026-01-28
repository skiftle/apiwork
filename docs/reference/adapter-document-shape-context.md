---
order: 16
prev: false
next: false
---

# Adapter::Document::ShapeContext

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape_context.rb#L14)

Context object for document shape building.

**Example: Accessing context**

```ruby
def build
  type_name = context.representation_class.root_key.singular.to_sym
  object.reference type_name
end
```

## Instance Methods

### #capabilities

`#capabilities`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape_context.rb#L21)

**Returns**

`Array<Capability::Base>` — adapter capabilities

---

### #capability_shapes

`#capability_shapes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape_context.rb#L38)

Returns capability shapes keyed by capability name.
Only includes capabilities that apply to the current type.

**Returns**

`Hash{Symbol => Apiwork::Object}`

---

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape_context.rb#L17)

**Returns**

`Class` — the representation class

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape_context.rb#L25)

**Returns**

`Symbol` — the document type (:record or :collection)

---
