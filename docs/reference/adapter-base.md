---
order: 9
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

  def render_record(record, schema_class, action_summary)
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

Sets or returns the adapter name identifier.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the adapter name to set |

**Returns**

`Symbol`, `nil` — the adapter name, or nil if not set

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L31)

Defines a configuration option for the spec or adapter.

Options can be passed to `.generate` or set via environment variables.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the option name |
| `type` | `Symbol` | the option type (:symbol, :string, :boolean, :integer) |
| `default` | `Object, nil` | default value if not provided |
| `enum` | `Array, nil` | allowed values |

**Returns**

`void`

**Example: Simple option**

```ruby
option :locale, type: :symbol, default: :en
```

**Example: Option with enum**

```ruby
option :format, type: :symbol, enum: [:json, :yaml]
```

---

## Instance Methods

### #register_api

`#register_api(registrar, schema_summary)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L42)

Registers types from schemas for the API.
Override to customize type registration.

**See also**

- [Adapter::APIRegistrar](adapter-api-registrar)
- [Adapter::SchemaSummary](adapter-schema-summary)

---

### #register_contract

`#register_contract(registrar, schema_class, actions:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L50)

Registers types for a contract.
Override to customize contract type registration.

**See also**

- [Adapter::ContractRegistrar](adapter-contract-registrar)

---

### #render_collection

`#render_collection(collection, schema_class, action_summary)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L62)

Renders a collection response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `collection` | `Enumerable` | the records to render |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |
| `action_summary` | `ActionSummary` | request context |

**Returns**

`Hash` — the response hash

**See also**

- [Adapter::ActionSummary](adapter-action-summary)

---

### #render_error

`#render_error(layer, issues, action_summary)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L86)

Renders an error response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `Symbol` | the error layer (:http, :contract, :domain) |
| `issues` | `Array<Issue>` | the validation issues |
| `action_summary` | `ActionSummary` | request context |

**Returns**

`Hash` — the error response hash

**See also**

- [Issue](issue)

---

### #render_record

`#render_record(record, schema_class, action_summary)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L74)

Renders a single record response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `Object` | the record to render |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |
| `action_summary` | `ActionSummary` | request context |

**Returns**

`Hash` — the response hash

**See also**

- [Adapter::ActionSummary](adapter-action-summary)

---

### #transform_request

`#transform_request(hash, schema_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L97)

Transforms incoming request parameters.
Override to customize key casing, unwrapping, etc.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash` | `Hash` | the request parameters |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass (optional) |

**Returns**

`Hash` — the transformed parameters

---

### #transform_response

`#transform_response(hash, schema_class)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L108)

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
