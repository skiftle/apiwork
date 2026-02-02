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

### #array

`#array(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#array](api-object#array)

---

### #array?

`#array?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#array?](api-object#array?)

---

### #binary

`#binary(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#binary](api-object#binary)

---

### #binary?

`#binary?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#binary?](api-object#binary?)

---

### #boolean

`#boolean(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#boolean](api-object#boolean)

---

### #boolean?

`#boolean?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#boolean?](api-object#boolean?)

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

- [API::Object#date](api-object#date)

---

### #date?

`#date?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#date?](api-object#date?)

---

### #datetime

`#datetime(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#datetime](api-object#datetime)

---

### #datetime?

`#datetime?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#datetime?](api-object#datetime?)

---

### #decimal

`#decimal(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#decimal](api-object#decimal)

---

### #decimal?

`#decimal?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#decimal?](api-object#decimal?)

---

### #extends

`#extends(type)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#extends](api-object#extends)

---

### #integer

`#integer(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#integer](api-object#integer)

---

### #integer?

`#integer?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#integer?](api-object#integer?)

---

### #literal

`#literal(name, value:, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#literal](api-object#literal)

---

### #merge!

`#merge!(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#merge!](api-object#merge!)

---

### #merge_shape!

`#merge_shape!(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#merge_shape!](api-object#merge-shape!)

---

### #metadata_shapes

`#metadata_shapes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L53)

**Returns**

[API::Object](api-object) — aggregated capability shapes to merge

---

### #number

`#number(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#number](api-object#number)

---

### #number?

`#number?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#number?](api-object#number?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#object](api-object#object)

---

### #object?

`#object?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#object?](api-object#object?)

---

### #reference

`#reference(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#reference](api-object#reference)

---

### #reference?

`#reference?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#reference?](api-object#reference?)

---

### #root_key

`#root_key`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L58)

**Returns**

[RootKey](representation-root-key) — the root key for the representation

**See also**

- [Representation::RootKey](representation-root-key)

---

### #string

`#string(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#string](api-object#string)

---

### #string?

`#string?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#string?](api-object#string?)

---

### #time

`#time(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#time](api-object#time)

---

### #time?

`#time?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#time?](api-object#time?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#union](api-object#union)

---

### #union?

`#union?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#union?](api-object#union?)

---

### #uuid

`#uuid(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#uuid](api-object#uuid)

---

### #uuid?

`#uuid?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/wrapper/shape.rb#L158)

**See also**

- [API::Object#uuid?](api-object#uuid?)

---
