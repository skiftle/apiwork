---
order: 21
prev: false
next: false
---

# MetadataShape

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L18)

Shape builder for operation metadata.

Provides [#options](#options) for accessing capability configuration,
plus all DSL methods from [API::Object](/reference/api/object) for defining structure.
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

- [API::Object#array](/reference/api/object#array)

---

### #array?

`#array?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#array?](/reference/api/object#array?)

---

### #binary

`#binary(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#binary](/reference/api/object#binary)

---

### #binary?

`#binary?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#binary?](/reference/api/object#binary?)

---

### #boolean

`#boolean(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#boolean](/reference/api/object#boolean)

---

### #boolean?

`#boolean?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#boolean?](/reference/api/object#boolean?)

---

### #date

`#date(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#date](/reference/api/object#date)

---

### #date?

`#date?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#date?](/reference/api/object#date?)

---

### #datetime

`#datetime(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#datetime](/reference/api/object#datetime)

---

### #datetime?

`#datetime?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#datetime?](/reference/api/object#datetime?)

---

### #decimal

`#decimal(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#decimal](/reference/api/object#decimal)

---

### #decimal?

`#decimal?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#decimal?](/reference/api/object#decimal?)

---

### #integer

`#integer(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#integer](/reference/api/object#integer)

---

### #integer?

`#integer?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#integer?](/reference/api/object#integer?)

---

### #literal

`#literal(name, value:, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#literal](/reference/api/object#literal)

---

### #merge

`#merge(other)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#merge](/reference/api/object#merge)

---

### #number

`#number(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#number](/reference/api/object#number)

---

### #number?

`#number?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#number?](/reference/api/object#number?)

---

### #object

`#object(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#object](/reference/api/object#object)

---

### #object?

`#object?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#object?](/reference/api/object#object?)

---

### #options

`#options`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L29)

The capability options for this metadata shape.

**Returns**

[Configuration](/reference/configuration/)

---

### #reference

`#reference(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#reference](/reference/api/object#reference)

---

### #reference?

`#reference?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#reference?](/reference/api/object#reference?)

---

### #string

`#string(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#string](/reference/api/object#string)

---

### #string?

`#string?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#string?](/reference/api/object#string?)

---

### #time

`#time(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#time](/reference/api/object#time)

---

### #time?

`#time?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#time?](/reference/api/object#time?)

---

### #union

`#union(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#union](/reference/api/object#union)

---

### #union?

`#union?(name, **options, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#union?](/reference/api/object#union?)

---

### #uuid

`#uuid(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#uuid](/reference/api/object#uuid)

---

### #uuid?

`#uuid?(name, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/capability/operation/metadata_shape.rb#L121)

**See also**

- [API::Object#uuid?](/reference/api/object#uuid?)

---
