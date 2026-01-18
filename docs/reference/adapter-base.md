---
order: 12
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L26)

Base class for adapters.

Subclass this to create custom response formats (JSON:API, HAL, etc.).
Use the hooks DSL to define request/response transformations.

**Example: Custom adapter with hooks**

```ruby
class JSONAPIAdapter < Apiwork::Adapter::Base
  adapter_name :jsonapi

  response do
    record do
      render { |data, schema_class, state|
        { data: { type: schema_class.root_key.singular, attributes: data } }
      }
    end
  end
end

# Register the adapter
Apiwork::Adapter.register(JSONAPIAdapter)
```

## Class Methods

### .adapter_name

`.adapter_name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L35)

The adapter name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Symbol, nil` | the adapter name to set |

**Returns**

`Symbol`, `nil`

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L50)

Defines a configuration option.

For nested options, use `type: :hash` with a block. Inside the block,
call `option` to define child options.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | option name |
| `type` | `Symbol` | :symbol, :string, :integer, :boolean, or :hash |
| `default` | `Object, nil` | default value |
| `enum` | `Array, nil` | allowed values |

**Returns**

`void`

**See also**

- [Configuration::Option](configuration-option)

**Example: Symbol option**

```ruby
option :locale, type: :symbol, default: :en
```

**Example: String option with enum**

```ruby
option :version, type: :string, default: '5', enum: %w[4 5]
```

**Example: Nested options**

```ruby
option :pagination, type: :hash do
  option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
  option :default_size, type: :integer, default: 20
  option :max_size, type: :integer, default: 100
end
```

---

### .register

`.register(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L51)

Defines registration hooks for API and contract setup.

**Example**

```ruby
register do
  api { |registrar, capabilities| ... }
  contract { |registrar, schema_class, actions| ... }
end
```

---

### .request

`.request(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L69)

Defines request transformation hooks.

**Example**

```ruby
request do
  before_validation { |request| request.transform(&:deep_symbolize_keys) }
  after_validation { |request| request }
end
```

---

### .response

`.response(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L98)

Defines response transformation hooks.

**Example**

```ruby
response do
  record do
    prepare { |record, state| ... }
    render { |data, state| ... }
  end
  collection do
    prepare { |collection, state| ... }
    render { |result, state| ... }
  end
  error do
    prepare { |issues, state| ... }
    render { |issues, state| ... }
  end
  finalize { |response| response }
end
```

---
