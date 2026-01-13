---
order: 40
prev: false
next: false
---

# Introspection::Enum

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L37)

**Returns**

`Boolean` — whether this enum is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L25)

**Returns**

`String`, `nil` — enum description

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L31)

**Returns**

`String`, `nil` — example value

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L43)

**Returns**

`Hash` — structured representation

---

### #values

`#values`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L19)

**Returns**

`Array<String>` — allowed enum values

---
