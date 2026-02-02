---
order: 24
prev: false
next: false
---

# Adapter::Wrapper::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L28)

Base class for wrapper shapes.

Subclass to define response type structure for record or collection wrappers.
The block is evaluated via instance_exec, providing access to type DSL methods
and helpers like root_key and metadata_shapes.

**Example: Custom shape class**

```ruby
class MyShape < Wrapper::Shape
  def build
    reference(:invoice)
    object?(:meta)
    merge_shape!(metadata_shapes)
  end
end
```

**Example: Inline shape block**

```ruby
shape do
  reference(root_key.singular.to_sym)
  object?(:meta)
  merge_shape!(metadata_shapes)
end
```

## Instance Methods

### #data_type

`#data_type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L49)

**Returns**

`Symbol`, `nil` — the data type name from serializer

---

### #metadata_shapes

`#metadata_shapes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L53)

**Returns**

[API::Object](api-object) — aggregated capability shapes to merge

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L58)

**Returns**

[RootKey](representation-root-key) — the root key for the representation

**See also**

- [Representation::RootKey](representation-root-key)

---
