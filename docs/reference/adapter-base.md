---
order: 6
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
class JsonApiAdapter < Apiwork::Adapter::Base
  adapter_name :jsonapi

  def render_record(record, schema_class, action_data)
    { data: { type: '...', attributes: '...' } }
  end
end

# Register the adapter
Apiwork::Adapter.register(JsonApiAdapter)
```

## Instance Methods

### #register_api(registrar, schema_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L35)

Registers types from schemas for the API.
Override to customize type registration.

---

### #register_contract(registrar, schema_class, actions:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L42)

Registers types for a contract.
Override to customize contract type registration.

---

### #render_collection(collection, schema_class, action_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L53)

Renders a collection response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `collection` | `Enumerable` | the records to render |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |
| `action_data` | `ActionData` | request context |

**Returns**

`Hash` — the response hash

---

### #render_error(issues, action_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L74)

Renders an error response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `issues` | `Array<Issue>` | the validation issues |
| `action_data` | `ActionData` | request context |

**Returns**

`Hash` — the error response hash

---

### #render_record(record, schema_class, action_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L64)

Renders a single record response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `Object` | the record to render |
| `schema_class` | `Class` | a [Schema::Base](schema-base) subclass |
| `action_data` | `ActionData` | request context |

**Returns**

`Hash` — the response hash

---

### #transform_request(hash, schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L85)

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

### #transform_response(hash, schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L96)

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
