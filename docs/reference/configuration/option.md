---
order: 36
prev: false
next: false
---

# Option

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration/option.rb#L26)

Block context for nested configuration options.

Used inside `option :name, type: :hash do ... end` blocks
in [Adapter::Base](/reference/adapter/base) and [Export::Base](/reference/export/base) subclasses.

**Example: instance_eval style**

```ruby
option :pagination, type: :hash do
  option :strategy, type: :symbol, default: :offset
  option :default_size, type: :integer, default: 20
end
```

**Example: yield style**

```ruby
option :pagination, type: :hash do |option|
  option.option :strategy, type: :symbol, default: :offset
  option.option :default_size, type: :integer, default: 20
end
```

## Instance Methods

### #option

`#option(name, default: nil, enum: nil, type:, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configuration/option.rb#L69)

Defines a nested option.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the option name |
| `type` | `Symbol` |  | :symbol, :string, :integer, :boolean, or :hash |
| `default` | `Object`, `nil` | `nil` | the default value |
| `enum` | `Array`, `nil` | `nil` | allowed values |

</div>

**Returns**

`void`

**Yields** [Option](/reference/configuration/option)

**Example: instance_eval style**

```ruby
option :pagination, type: :hash do
  option :strategy, type: :symbol, default: :offset
  option :default_size, type: :integer, default: 20
end
```

**Example: yield style**

```ruby
option :pagination, type: :hash do |option|
  option.option :strategy, type: :symbol, default: :offset
  option.option :default_size, type: :integer, default: 20
end
```

---
