---
order: 35
prev: false
next: false
---

# Configuration

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration.rb#L16)

Typed access to configuration values with automatic defaults.

**Example: Reading values**

```ruby
config.pagination.default_size  # => 20
config.pagination.strategy      # => :offset
```

**Example: Using dig for dynamic access**

```ruby
config.dig(:pagination, :default_size)  # => 20
```

## Modules

- [Option](./option)

## Instance Methods

### #dig

`#dig(*keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration.rb#L65)

Accesses nested configuration values by key path.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`keys`** | `Symbol` |  | One or more keys to traverse. |

</div>

**Example**

```ruby
config.dig(:pagination)             # => #<Apiwork::Configuration:...>
config.dig(:pagination, :strategy)  # => :offset
```

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration.rb#L76)

Converts the configuration to a hash.

**Returns**

`Hash`

**Example**

```ruby
config.to_h  # => { pagination: { strategy: :offset, default_size: 20 } }
```

---
