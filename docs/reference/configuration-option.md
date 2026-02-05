---
order: 34
prev: false
next: false
---

# Configuration::Option

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration/option.rb#L20)

Block context for nested configuration options.

Used inside `option :name, type: :hash do ... end` blocks
in [Adapter::Base](adapter-base) and [Export::Base](export-base) subclasses.

**Example: Nested pagination options**

```ruby
option :pagination, type: :hash do
  option :strategy, type: :symbol, default: :offset
  option :default_size, type: :integer, default: 20
end
```

## Instance Methods

### #option

`#option(name, default: nil, enum: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration/option.rb#L47)

Defines a nested option.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` |  |
| `type` | `Symbol` | :symbol, :string, :integer, :boolean, or :hash |
| `default` | `Object, nil` |  |
| `enum` | `Array, nil` |  |

---
