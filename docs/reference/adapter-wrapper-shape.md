---
order: 20
prev: false
next: false
---

# Adapter::Wrapper::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L28)

Base class for wrapper shapes.

Subclass to define response type structure for record or collection wrappers.
The block receives the shape instance with delegated type definition methods
and access to root_key and metadata.

**Example: Custom shape class**

```ruby
class MyShape < Wrapper::Shape
  def build
    reference(:invoice)
    object?(:meta)
    merge_shape!(metadata)
  end
end
```

**Example: Inline shape block**

```ruby
shape do |shape|
  shape.reference(shape.root_key.singular.to_sym)
  shape.object?(:meta)
  shape.merge_shape!(shape.metadata)
end
```

## Instance Methods

### #data_type

`#data_type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L49)

**Returns**

`Symbol`, `nil` — the data type name from serializer

---

### #metadata

`#metadata`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L53)

**Returns**

[API::Object](api-object) — capability shapes to merge

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L58)

**Returns**

[RootKey](representation-root-key) — the root key for the representation

**See also**

- [Representation::RootKey](representation-root-key)

---
