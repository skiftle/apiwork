---
order: 21
prev: false
next: false
---

# MetadataShape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L18)

Shape builder for operation metadata.

Provides [#options](#options) for accessing capability configuration,
plus all DSL methods from [API::Object](/reference/apiwork/api/object) for defining structure.
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#array](/reference/apiwork/api/object#array)

---

### #array?

`#array?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#array?](/reference/apiwork/api/object#array?)

---

### #binary

`#binary(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#binary](/reference/apiwork/api/object#binary)

---

### #binary?

`#binary?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#binary?](/reference/apiwork/api/object#binary?)

---

### #boolean

`#boolean(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#boolean](/reference/apiwork/api/object#boolean)

---

### #boolean?

`#boolean?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#boolean?](/reference/apiwork/api/object#boolean?)

---

### #date

`#date(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#date](/reference/apiwork/api/object#date)

---

### #date?

`#date?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#date?](/reference/apiwork/api/object#date?)

---

### #datetime

`#datetime(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#datetime](/reference/apiwork/api/object#datetime)

---

### #datetime?

`#datetime?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#datetime?](/reference/apiwork/api/object#datetime?)

---

### #decimal

`#decimal(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#decimal](/reference/apiwork/api/object#decimal)

---

### #decimal?

`#decimal?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#decimal?](/reference/apiwork/api/object#decimal?)

---

### #integer

`#integer(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#integer](/reference/apiwork/api/object#integer)

---

### #integer?

`#integer?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#integer?](/reference/apiwork/api/object#integer?)

---

### #literal

`#literal(name, value:, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#literal](/reference/apiwork/api/object#literal)

---

### #merge

`#merge(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#merge](/reference/apiwork/api/object#merge)

---

### #number

`#number(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#number](/reference/apiwork/api/object#number)

---

### #number?

`#number?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#number?](/reference/apiwork/api/object#number?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#object](/reference/apiwork/api/object#object)

---

### #object?

`#object?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#object?](/reference/apiwork/api/object#object?)

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L29)

The capability options for this metadata shape.

**Returns**

[Configuration](/reference/apiwork/configuration/)

---

### #reference

`#reference(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#reference](/reference/apiwork/api/object#reference)

---

### #reference?

`#reference?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#reference?](/reference/apiwork/api/object#reference?)

---

### #string

`#string(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#string](/reference/apiwork/api/object#string)

---

### #string?

`#string?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#string?](/reference/apiwork/api/object#string?)

---

### #time

`#time(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#time](/reference/apiwork/api/object#time)

---

### #time?

`#time?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#time?](/reference/apiwork/api/object#time?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#union](/reference/apiwork/api/object#union)

---

### #union?

`#union?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#union?](/reference/apiwork/api/object#union?)

---

### #uuid

`#uuid(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#uuid](/reference/apiwork/api/object#uuid)

---

### #uuid?

`#uuid?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#uuid?](/reference/apiwork/api/object#uuid?)

---
