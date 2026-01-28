---
order: 15
prev: false
next: false
---

# Adapter::Document::Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape.rb#L26)

Base class for document shapes.

Subclass to define response type structure for record or collection documents.
The block is evaluated in the context of a [ShapeBuilder](shape-builder), providing direct
access to type definition methods and context.

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
shape do
  reference context.representation_class.root_key.singular.to_sym
  object? :meta
end
```

## Instance Methods

### #context

`#context`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/document/shape.rb#L44)

**Returns**

[ShapeContext](adapter-document-shape-context) — the shape context

---
