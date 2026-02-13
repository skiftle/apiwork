---
order: 34
prev: false
next: false
---

# Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L28)

Base class for wrapper shapes.

Subclass to define response type structure for record or collection wrappers.
The block is evaluated via instance_exec, providing access to type DSL methods
and helpers like root_key and [#metadata_type_names](#metadata-type-names).

**Example: Custom shape class**

```ruby
class MyShape < Wrapper::Shape
  def apply
    reference(:invoice)
    object?(:meta)
    metadata_type_names.each { |type_name| merge(type_name) }
  end
end
```

**Example: Inline shape block**

```ruby
shape do
  reference(root_key.singular.to_sym)
  object?(:meta)
  metadata_type_names.each { |type_name| merge(type_name) }
end
```

## Instance Methods

### #array

`#array(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#array](/reference/api/object#array)

---

### #array?

`#array?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#array?](/reference/api/object#array?)

---

### #binary

`#binary(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#binary](/reference/api/object#binary)

---

### #binary?

`#binary?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#binary?](/reference/api/object#binary?)

---

### #boolean

`#boolean(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#boolean](/reference/api/object#boolean)

---

### #boolean?

`#boolean?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#boolean?](/reference/api/object#boolean?)

---

### #data_type

`#data_type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L46)

The data type for this shape.

**Returns**

`Symbol`, `nil`

---

### #date

`#date(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#date](/reference/api/object#date)

---

### #date?

`#date?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#date?](/reference/api/object#date?)

---

### #datetime

`#datetime(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#datetime](/reference/api/object#datetime)

---

### #datetime?

`#datetime?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#datetime?](/reference/api/object#datetime?)

---

### #decimal

`#decimal(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#decimal](/reference/api/object#decimal)

---

### #decimal?

`#decimal?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#decimal?](/reference/api/object#decimal?)

---

### #extends

`#extends(type)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#extends](/reference/api/object#extends)

---

### #integer

`#integer(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#integer](/reference/api/object#integer)

---

### #integer?

`#integer?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#integer?](/reference/api/object#integer?)

---

### #literal

`#literal(name, value:, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#literal](/reference/api/object#literal)

---

### #merge

`#merge(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#merge](/reference/api/object#merge)

---

### #metadata_type_names

`#metadata_type_names`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L56)

The metadata type names for this shape.

Auto-generated type names from capability
[Adapter::Capability::Operation::Base.metadata_shape](/reference/adapter/capability/operation/base#metadata-shape) definitions. Use with [#merge](#merge)
to include capability metadata fields in the shape.

**Returns**

`Array<Symbol>`

---

### #number

`#number(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#number](/reference/api/object#number)

---

### #number?

`#number?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#number?](/reference/api/object#number?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#object](/reference/api/object#object)

---

### #object?

`#object?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#object?](/reference/api/object#object?)

---

### #reference

`#reference(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#reference](/reference/api/object#reference)

---

### #reference?

`#reference?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#reference?](/reference/api/object#reference?)

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L62)

The root key for this shape.

**Returns**

[RootKey](/reference/representation/root-key)

---

### #string

`#string(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#string](/reference/api/object#string)

---

### #string?

`#string?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#string?](/reference/api/object#string?)

---

### #time

`#time(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#time](/reference/api/object#time)

---

### #time?

`#time?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#time?](/reference/api/object#time?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#union](/reference/api/object#union)

---

### #union?

`#union?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#union?](/reference/api/object#union?)

---

### #uuid

`#uuid(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#uuid](/reference/api/object#uuid)

---

### #uuid?

`#uuid?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L157)

**See also**

- [API::Object#uuid?](/reference/api/object#uuid?)

---
