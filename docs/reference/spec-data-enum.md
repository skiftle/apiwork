---
order: 27
prev: false
next: false
---

# Spec::Data::Enum

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/enum.rb#L16)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/enum.rb#L44)

**Returns**

`Boolean` — whether this enum is deprecated

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/enum.rb#L32)

**Returns**

`String`, `nil` — enum description

---

### #example

`#example`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/enum.rb#L38)

**Returns**

`String`, `nil` — example value

---

### #values

`#values`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/enum.rb#L26)

**Returns**

`Array<String>` — allowed enum values

---
