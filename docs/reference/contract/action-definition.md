---
order: 54
prev: false
next: false
---

# ActionDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L5)

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L6)

Returns the value of attribute action_name.

---

### #as_json()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L38)

---

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L6)

Returns the value of attribute contract_class.

---

### #deprecated(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L102)

Marks this action as deprecated.

Deprecated actions are flagged in OpenAPI specs.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Boolean` | deprecation status (optional) |

**Returns**

`Boolean, nil` — whether deprecated

**Example**

```ruby
action :legacy_create do
  deprecated true
end
```

---

### #description(text = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L70)

Sets a detailed description for this action.

Used in OpenAPI specs as the operation description.
Supports Markdown formatting.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | description text (optional) |

**Returns**

`String, nil` — the description

**Example**

```ruby
action :create do
  description 'Creates a new invoice and sends notification email.'
end
```

---

### #initialize(action_name:, contract_class:, replace: = false)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L11)

**Returns**

`ActionDefinition` — a new instance of ActionDefinition

---

### #introspect(locale: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L34)

---

### #operation_id(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L118)

Sets a custom OpenAPI operationId.

By default, operationId is auto-generated from resource and action name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | custom operation ID (optional) |

**Returns**

`String, nil` — the operation ID

**Example**

```ruby
action :create do
  operation_id 'createNewInvoice'
end
```

---

### #raises(*error_code_keys)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L135)

Declares error codes this action may return.

Error codes must be registered via ErrorCode.register.
These appear in OpenAPI specs as possible error responses.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error_code_keys` | `Array<Symbol>` | error code keys |

**Example**

```ruby
action :show do
  raises :not_found, :forbidden
end
```

---

### #request(replace: = false, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L167)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

`RequestDefinition` — the request definition

**Example**

```ruby
action :create do
  request do
    query { param :dry_run, type: :boolean, optional: true }
    body { param :title, type: :string }
  end
end
```

---

### #request_definition()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L6)

Returns the value of attribute request_definition.

---

### #resets_request?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L26)

**Returns**

`Boolean` — 

---

### #resets_response?()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L30)

**Returns**

`Boolean` — 

---

### #response(replace: = false, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L196)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

`ResponseDefinition` — the response definition

**Example**

```ruby
action :show do
  response do
    body { param :id; param :title }
  end
end
```

**Example: No content response**

```ruby
action :destroy do
  response { no_content! }
end
```

---

### #response_definition()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L6)

Returns the value of attribute response_definition.

---

### #serialize_data(data, context: = {}, include: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L206)

---

### #summary(text = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L53)

Sets a short summary for this action.

Used in OpenAPI specs as the operation summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | summary text (optional) |

**Returns**

`String, nil` — the summary

**Example**

```ruby
action :create do
  summary 'Create a new invoice'
end
```

---

### #tags(*tags_list)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L86)

Sets OpenAPI tags for grouping this action.

Tags help organize actions in generated documentation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags_list` | `Array<String,Symbol>` | tag names |

**Returns**

`Array, nil` — the tags

**Example**

```ruby
action :create do
  tags :billing, :invoices
end
```

---
