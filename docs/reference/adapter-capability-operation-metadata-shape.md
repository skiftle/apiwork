---
order: 19
prev: false
next: false
---

# Adapter::Capability::Operation::MetadataShape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L18)

Shape builder for operation metadata.

Provides [#options](#options) for accessing capability configuration,
plus all DSL methods from [API::Object](api-object) for defining structure.
Used by operations to define their metadata contribution.

**Example: Add pagination metadata shape**

```ruby
metadata_shape do
  reference :pagination
end
```

## Instance Methods

### #array

`#array(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#array](api-object#array)

---

### #array?

`#array?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#array?](api-object#array?)

---

### #binary

`#binary(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#binary](api-object#binary)

---

### #binary?

`#binary?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#binary?](api-object#binary?)

---

### #boolean

`#boolean(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#boolean](api-object#boolean)

---

### #boolean?

`#boolean?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#boolean?](api-object#boolean?)

---

### #date

`#date(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#date](api-object#date)

---

### #date?

`#date?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#date?](api-object#date?)

---

### #datetime

`#datetime(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#datetime](api-object#datetime)

---

### #datetime?

`#datetime?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#datetime?](api-object#datetime?)

---

### #decimal

`#decimal(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#decimal](api-object#decimal)

---

### #decimal?

`#decimal?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#decimal?](api-object#decimal?)

---

### #integer

`#integer(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#integer](api-object#integer)

---

### #integer?

`#integer?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#integer?](api-object#integer?)

---

### #literal

`#literal(name, value:, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#literal](api-object#literal)

---

### #merge!

`#merge!(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#merge!](api-object#merge!)

---

### #number

`#number(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#number](api-object#number)

---

### #number?

`#number?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#number?](api-object#number?)

---

### #object?

`#object?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#object?](api-object#object?)

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L21)

**Returns**

[Configuration](configuration) — capability options

---

### #reference

`#reference(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#reference](api-object#reference)

---

### #reference?

`#reference?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#reference?](api-object#reference?)

---

### #string

`#string(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#string](api-object#string)

---

### #string?

`#string?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#string?](api-object#string?)

---

### #time

`#time(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#time](api-object#time)

---

### #time?

`#time?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#time?](api-object#time?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#union](api-object#union)

---

### #union?

`#union?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#union?](api-object#union?)

---

### #uuid

`#uuid(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#uuid](api-object#uuid)

---

### #uuid?

`#uuid?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L113)

**See also**

- [API::Object#uuid?](api-object#uuid?)

---
