---
order: 13
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L22)

Base class for adapters.

Subclass this to create custom response formats (JSON:API, HAL, etc.).
Override the render and transform methods to customize behavior.

**Example: Custom adapter**

```ruby
class JSONAPIAdapter < Apiwork::Adapter::Base
  adapter_name :jsonapi

  def render_record(record, schema_class, state)
    { data: { type: '...', attributes: '...' } }
  end
end

# Register the adapter
Apiwork::Adapter.register(JSONAPIAdapter)
```

## Class Methods

### .adapter_name

`.adapter_name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L31)

The adapter name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the adapter name to set |

**Returns**

`Symbol`, `nil`

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L40)

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

## Instance Methods

### #register_api

`#register_api(registrar, capabilities)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L42)

Registers types from schemas for the API.
Override to customize type registration.

**See also**

- [Adapter::APIRegistrar](adapter-api-registrar)
- [Adapter::Capabilities](adapter-capabilities)

---

### #register_contract

`#register_contract(registrar, schema_class, actions)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L75)

Registers types for a contract.

Called once per contract during API initialization. Override to customize
how request/response types are generated from schema definitions.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `registrar` | `Adapter::ContractRegistrar` | for defining contract-scoped types |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass with attribute/association metadata |
| `actions` | `Hash{Symbol => Adapter::Action}` | resource actions. Keys are action names (:index, :show, :create, :update, :destroy, or custom) |

**See also**

- [Adapter::ContractRegistrar](adapter-contract-registrar)
- [Schema::Base](schema-base)
- [Adapter::Action](adapter-action)

**Example**

```ruby
def register_contract(registrar, schema_class, actions)
  actions.each do |name, action|
    definition = registrar.action(name)

    if action.collection?
      definition.request do
        query do
          integer :page, optional: true
        end
      end
    end
  end
end
```

---

### #render_collection

`#render_collection(collection, schema_class, state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L87)

Renders a collection response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `collection` | `Enumerable` | the records to render |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |
| `state` | `Adapter::RenderState` | runtime context |

**Returns**

`Hash` — the response hash

**See also**

- [Adapter::RenderState](adapter-render-state)

---

### #render_error

`#render_error(layer, issues, state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L111)

Renders an error response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `Symbol` | the error layer (:http, :contract, :domain) |
| `issues` | `Array<Issue>` | the validation issues |
| `state` | `Adapter::RenderState` | runtime context |

**Returns**

`Hash` — the error response hash

**See also**

- [Issue](issue)

---

### #render_record

`#render_record(record, schema_class, state)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L99)

Renders a single record response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `Object` | the record to render |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |
| `state` | `Adapter::RenderState` | runtime context |

**Returns**

`Hash` — the response hash

**See also**

- [Adapter::RenderState](adapter-render-state)

---

### #transform_request

`#transform_request(hash)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L121)

Transforms incoming request parameters.
Override to customize key casing, unwrapping, etc.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash` | `Hash` | the request parameters |

**Returns**

`Hash` — the transformed parameters

---

### #transform_response

`#transform_response(hash, schema_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L132)

Transforms outgoing response data.
Override to customize key casing, wrapping, etc.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash` | `Hash` | the response data |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass (optional) |

**Returns**

`Hash` — the transformed response

---
