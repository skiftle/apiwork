---
order: 33
prev: false
next: false
---

# Shape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L28)

Base class for wrapper shapes.

Subclass to define response type structure for record or collection wrappers.
The block is evaluated via instance_exec, providing access to type DSL methods
and helpers like root_key and metadata_shapes.

**Example: Custom shape class**

```ruby
class MyShape < Wrapper::Shape
  def apply
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

### #array

`#array(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#array](/reference/api/object#array)

---

### #array?

`#array?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#array?](/reference/api/object#array?)

---

### #binary

`#binary(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#binary](/reference/api/object#binary)

---

### #binary?

`#binary?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#binary?](/reference/api/object#binary?)

---

### #boolean

`#boolean(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#boolean](/reference/api/object#boolean)

---

### #boolean?

`#boolean?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#boolean?](/reference/api/object#boolean?)

---

### #data_type

`#data_type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L49)

**Returns**

`Symbol`, `nil` — the data type name from serializer

---

### #date

`#date(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#date](/reference/api/object#date)

---

### #date?

`#date?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#date?](/reference/api/object#date?)

---

### #datetime

`#datetime(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#datetime](/reference/api/object#datetime)

---

### #datetime?

`#datetime?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#datetime?](/reference/api/object#datetime?)

---

### #decimal

`#decimal(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#decimal](/reference/api/object#decimal)

---

### #decimal?

`#decimal?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#decimal?](/reference/api/object#decimal?)

---

### #extends

`#extends(type)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#extends](/reference/api/object#extends)

---

### #integer

`#integer(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#integer](/reference/api/object#integer)

---

### #integer?

`#integer?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#integer?](/reference/api/object#integer?)

---

### #literal

`#literal(name, value:, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#literal](/reference/api/object#literal)

---

### #merge!

`#merge!(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#merge!](/reference/api/object#merge!)

---

### #merge_shape!

`#merge_shape!(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#merge_shape!](/reference/api/object#merge-shape!)

---

### #metadata_shapes

`#metadata_shapes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L53)

**Returns**

[API::Object](/reference/api/object) — aggregated capability shapes to merge

---

### #number

`#number(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#number](/reference/api/object#number)

---

### #number?

`#number?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#number?](/reference/api/object#number?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#object](/reference/api/object#object)

---

### #object?

`#object?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#object?](/reference/api/object#object?)

---

### #reference

`#reference(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#reference](/reference/api/object#reference)

---

### #reference?

`#reference?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#reference?](/reference/api/object#reference?)

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L58)

**Returns**

[RootKey](/reference/representation/root-key) — the root key for the representation

**See also**

- [Representation::RootKey](/reference/representation/root-key)

---

### #string

`#string(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#string](/reference/api/object#string)

---

### #string?

`#string?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#string?](/reference/api/object#string?)

---

### #time

`#time(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#time](/reference/api/object#time)

---

### #time?

`#time?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#time?](/reference/api/object#time?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#union](/reference/api/object#union)

---

### #union?

`#union?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#union?](/reference/api/object#union?)

---

### #uuid

`#uuid(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#uuid](/reference/api/object#uuid)

---

### #uuid?

`#uuid?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#uuid?](/reference/api/object#uuid?)

---
