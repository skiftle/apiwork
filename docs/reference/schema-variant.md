---
order: 64
prev: false
next: false
---

# Schema::Variant

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/variant.rb#L15)

Represents a variant in a discriminated union.

Variants map discriminator values to their schema classes.
Used by adapters to serialize records based on their actual type.

**Example**

```ruby
variant = VehicleSchema.variants[:car]
variant.type          # => "Car"
variant.schema_class  # => CarSchema
```

## Instance Methods

### #schema_class

`#schema_class`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/variant.rb#L18)

**Returns**

[Schema::Base](schema-base) — the schema class for this variant

---

### #type

`#type`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/variant.rb#L22)

**Returns**

`String` — the discriminator value

---
