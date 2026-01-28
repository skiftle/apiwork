---
order: 16
prev: false
next: false
---

# Adapter::Document::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape.rb#L26)

Base class for document shapes.

Subclass to define response type structure for record or collection documents.
The block receives the shape instance with delegated type definition methods
and access to representation_class.

**Example: Custom shape class**

```ruby
class MyShape < Document::Shape
  def build
    reference :invoice
    object? :meta
  end
end
```

**Example: Inline shape block**

```ruby
shape do |shape|
  shape.reference shape.representation_class.root_key.singular.to_sym
  shape.object? :meta
end
```

## Instance Methods

### #representation_class

`#representation_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape.rb#L44)

**Returns**

[Class] — the representation class

---
