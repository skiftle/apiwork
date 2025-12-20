---
order: 30
prev: false
next: false
---

# Adapter::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L19)

Base class for adapters.

Subclass this to create custom response formats (JSON:API, HAL, etc.).
Override the render and transform methods to customize behavior.

**Example: Custom adapter**

```ruby
class JsonApiAdapter < Apiwork::Adapter::Base
  register_as :jsonapi

  def render_record(record, schema_class, action_data)
    { data: { type: '...', attributes: '...' } }
  end
end
```

## Instance Methods

### #register_api_types(type_registrar, schema_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L26)

Registers types from schemas for the API.
Override to customize type registration.

---

### #register_contract_types(type_registrar, schema_class, actions:)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L33)

Registers types for a contract.
Override to customize contract type registration.

---

### #render_collection(collection, schema_class, action_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L44)

Renders a collection response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `collection` | `Enumerable` | the records to render |
| `schema_class` | `Class` | the schema class |
| `action_data` | `ActionData` | request context |

**Returns**

`Hash` — the response hash

---

### #render_error(issues, action_data)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L65)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L55)

Renders a single record response.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `record` | `Object` | the record to render |
| `schema_class` | `Class` | the schema class |
| `action_data` | `ActionData` | request context |

**Returns**

`Hash` — the response hash

---

### #transform_request(hash, schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L76)

Transforms incoming request parameters.
Override to customize key casing, unwrapping, etc.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash` | `Hash` | the request parameters |
| `schema_class` | `Class` | the schema class (optional) |

**Returns**

`Hash` — the transformed parameters

---

### #transform_response(hash, schema_class)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/adapter/base.rb#L87)

Transforms outgoing response data.
Override to customize key casing, wrapping, etc.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `hash` | `Hash` | the response data |
| `schema_class` | `Class` | the schema class (optional) |

**Returns**

`Hash` — the transformed response

---
