---
order: 17
prev: false
next: false
---

# Configuration::Option

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration/option.rb#L9)

Configuration option definition.

Supports recursive nesting via [#hash](#hash).

## Instance Methods

### #option

`#option(name, default: nil, enum: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration/option.rb#L36)

Defines a nested option.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` |  |
| `type` | `Symbol` | :symbol, :string, :integer, :boolean, or :hash |
| `default` | `Object, nil` |  |
| `enum` | `Array, nil` |  |

---
