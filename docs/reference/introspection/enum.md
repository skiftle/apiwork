---
order: 60
prev: false
next: false
---

# Enum

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L12)

Wraps enum type definitions.

**Example**

```ruby
api.enums[:status].values       # => ["draft", "published", "archived"]
api.enums[:status].description  # => "Document status"
api.enums[:status].deprecated?  # => false
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L45)

Whether this enum is deprecated.

**Returns**

`Boolean`

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L29)

The description for this enum.

**Returns**

`String`, `nil`

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L37)

The example for this enum.

**Returns**

`String`, `nil`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L53)

Converts this enum to a hash.

**Returns**

`Hash`

---

### #values

`#values`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L21)

The values for this enum.

**Returns**

`Array<String>`

---
