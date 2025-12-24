---
order: 9
prev: false
next: false
---

# Contract::ActionDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L11)

Defines request/response structure for an action.

Part of the Adapter DSL. Returned by [Adapter::ContractRegistrar#define_action](adapter-contract-registrar#define-action).
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #action_name()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L24)

**Returns**

`Symbol` — the action name

---

### #contract_class()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L24)

**Returns**

`Class` — a [Contract::Base](contract-base) subclass

---

### #deprecated(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L124)

Marks this action as deprecated.

Deprecated actions are flagged in generated specs.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Boolean` | deprecation status (optional) |

**Returns**

`Boolean`, `nil` — whether deprecated

**Example**

```ruby
action :legacy_create do
  deprecated true
end
```

---

### #description(text = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L90)

Sets a detailed description for this action.

Used in generated specs as the operation description.
Supports Markdown formatting.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | description text (optional) |

**Returns**

`String`, `nil` — the description

**Example**

```ruby
action :create do
  description 'Creates a new invoice and sends notification email.'
end
```

---

### #operation_id(value = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L141)

Sets a custom operation ID.

By default, operation ID is auto-generated from resource and action name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | custom operation ID (optional) |

**Returns**

`String`, `nil` — the operation ID

**Example**

```ruby
action :create do
  operation_id 'createNewInvoice'
end
```

---

### #raises(*error_code_keys)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L159)

Declares error codes this action may return.

Error codes must be registered via ErrorCode.register.
These appear in generated specs as possible error responses.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L192)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[RequestDefinition](contract-request-definition) — the request definition

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L24)

**Returns**

[RequestDefinition](contract-request-definition), `nil` — the request definition

---

### #response(replace: = false, &block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L222)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[ResponseDefinition](contract-response-definition) — the response definition

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

### #summary(text = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L72)

Sets a short summary for this action.

Used in generated specs as the operation summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | summary text (optional) |

**Returns**

`String`, `nil` — the summary

**Example**

```ruby
action :create do
  summary 'Create a new invoice'
end
```

---

### #tags(*tags_list)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L107)

Sets tags for grouping this action.

Tags help organize actions in generated documentation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags_list` | `Array<String,Symbol>` | tag names |

**Returns**

`Array`, `nil` — the tags

**Example**

```ruby
action :create do
  tags :billing, :invoices
end
```

---
