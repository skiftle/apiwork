---
order: 64
prev: false
next: false
---

# Schema::Union::Variant

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union/variant.rb#L17)

Represents a variant in a discriminated union schema.

Variants map discriminator tags to their schema classes.
Used by adapters to serialize records based on their actual type.

**Example**

```ruby
variant = VehicleSchema.union.variants[:car]
variant.tag           # => :car
variant.type          # => "Car"
variant.schema_class  # => CarSchema
```

## Instance Methods

### #schema_class

`#schema_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union/variant.rb#L20)

**Returns**

[Schema::Base](schema-base) — the schema class for this variant

---

### #tag

`#tag`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union/variant.rb#L24)

**Returns**

`Symbol` — the discriminator tag

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union/variant.rb#L28)

**Returns**

`String` — the Rails STI type

---
