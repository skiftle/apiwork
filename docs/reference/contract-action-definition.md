---
order: 13
prev: false
next: false
---

# Contract::ActionDefinition

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L11)

Defines request/response structure for an action.

Returns [RequestDefinition](contract-request-definition) via `request` and [ResponseDefinition](contract-response-definition) via `response`.
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #deprecated

`#deprecated(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L104)

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

### #description

`#description(description = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L70)

Sets a detailed description for this action.

Used in generated specs as the operation description.
Supports Markdown formatting.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | `String` | description text (optional) |

**Returns**

`String`, `nil` — the description

**Example**

```ruby
action :create do
  description 'Creates a new invoice and sends notification email.'
end
```

---

### #operation_id

`#operation_id(operation_id = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L119)

Sets a custom operation ID.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `operation_id` | `String` | custom operation ID (optional) |

**Returns**

`String`, `nil` — the operation ID

**Example**

```ruby
action :create do
  operation_id 'createNewInvoice'
end
```

---

### #raises

`#raises(*error_code_keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L138)

Declares error codes this action may return.

Uses built-in error codes (:not_found, :forbidden, etc.) or custom codes
registered via ErrorCode.register. These appear in generated specs.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error_code_keys` | `Array<Symbol>` | error code keys |

**See also**

- [ErrorCode](spec-data-error-code)

**Example**

```ruby
action :show do
  raises :not_found, :forbidden
end
```

---

### #request

`#request(replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L172)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[RequestDefinition](contract-request-definition) — the request definition

**See also**

- [Contract::RequestDefinition](contract-request-definition)

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

### #response

`#response(replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L206)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[ResponseDefinition](contract-response-definition) — the response definition

**See also**

- [Contract::ResponseDefinition](contract-response-definition)

**Example**

```ruby
action :show do
  response do
    body do
      param :id
      param :title
    end
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

### #summary

`#summary(summary = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L52)

Sets a short summary for this action.

Used in generated specs as the operation summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `summary` | `String` | summary text (optional) |

**Returns**

`String`, `nil` — the summary

**Example**

```ruby
action :create do
  summary 'Create a new invoice'
end
```

---

### #tags

`#tags(*tags)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action_definition.rb#L87)

Sets tags for grouping this action.

Tags help organize actions in generated documentation.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags` | `Array<String,Symbol>` | tag names |

**Returns**

`Array`, `nil` — the tags

**Example**

```ruby
action :create do
  tags :billing, :invoices
end
```

---
