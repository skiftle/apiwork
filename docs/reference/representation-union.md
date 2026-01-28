---
order: 68
prev: false
next: false
---

# Representation::Union

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L17)

Configuration for discriminated union representations.

Holds the discriminator field name, Rails column, and registered variants.
Used by adapters to serialize records based on their actual type.

**Example**

```ruby
ClientRepresentation.union.discriminator # => :kind
ClientRepresentation.union.column        # => :type
ClientRepresentation.union.variants      # => {person: Union::Variant, company: Union::Variant}
```

## Instance Methods

### #column

`#column`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L24)

**Returns**

`Symbol` — Rails column name (typically :type)

---

### #discriminator

`#discriminator`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L20)

**Returns**

`Symbol` — key name for the discriminator

---

### #mapping

`#mapping`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L58)

Returns a mapping of tags to Rails STI types.

**Returns**

`Hash{Symbol => String}` — tag to type mapping

---

### #needs_transform?

`#needs_transform?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L50)

Returns whether any variant has a tag different from its type.

**Returns**

`Boolean` — true if transformation is needed

---

### #resolve

`#resolve(record)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L41)

Resolves which variant to use for a record.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `ActiveRecord::Base` | the record to resolve |

**Returns**

[Variant](representation-union-variant), `nil` — the matching variant or nil

---

### #variants

`#variants`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/representation/union.rb#L28)

**Returns**

Hash{Symbol =&gt; [Variant](representation-union-variant)} — registered variants

---
