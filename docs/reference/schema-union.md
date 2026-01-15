---
order: 64
prev: false
next: false
---

# Schema::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L17)

Configuration for discriminated union schemas.

Holds the discriminator field name, Rails column, and registered variants.
Used by adapters to serialize records based on their actual type.

**Example**

```ruby
ClientSchema.union.discriminator # => :kind
ClientSchema.union.column        # => :type
ClientSchema.union.variants      # => {person: Union::Variant, company: Union::Variant}
```

## Instance Methods

### #column

`#column`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L24)

**Returns**

`Symbol` — Rails column name (typically :type)

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L20)

**Returns**

`Symbol` — JSON field name for the discriminator

---

### #mapping

`#mapping`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L58)

Returns a mapping of tags to Rails STI types.

**Returns**

`Hash{Symbol => String}` — tag to type mapping

---

### #needs_transform?

`#needs_transform?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L50)

Returns whether any variant has a tag different from its type.

**Returns**

`Boolean` — true if transformation is needed

---

### #resolve

`#resolve(record)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L41)

Resolves which variant to use for a record.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `ActiveRecord::Base` | the record to resolve |

**Returns**

[Variant](schema-union-variant), `nil` — the matching variant or nil

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/schema/union.rb#L28)

**Returns**

Hash{Symbol =&gt; [Variant](schema-union-variant)} — registered variants

---
