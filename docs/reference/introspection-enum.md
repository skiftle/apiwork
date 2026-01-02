---
order: 30
prev: false
next: false
---

# Introspection::Enum

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L15)

Wraps enum type definitions.

**Example**

```ruby
data.enums.each do |enum|
  enum.name         # => :status
  enum.values       # => ["draft", "published", "archived"]
  enum.description  # => "Document status"
  enum.deprecated?  # => false
end
```

## Instance Methods

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L45)

**Returns**

`Boolean` — whether this enum is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L33)

**Returns**

`String`, `nil` — enum description

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L39)

**Returns**

`String`, `nil` — example value

---

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L18)

**Returns**

`Symbol` — enum name

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L51)

**Returns**

`Hash` — structured representation

---

### #values

`#values`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/enum.rb#L27)

**Returns**

`Array<String>` — allowed enum values

---
