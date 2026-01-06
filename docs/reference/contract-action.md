---
order: 13
prev: false
next: false
---

# Contract::Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L11)

Defines request/response structure for an action.

Returns [Request](contract-request) via `request` and [Response](contract-response) via `response`.
Use as a declarative builder - do not rely on internal state.

## Instance Methods

### #deprecated

`#deprecated`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L101)

Marks this action as deprecated.

Deprecated actions are flagged in generated exports.

**Returns**

`void`

**Example**

```ruby
action :legacy_create do
  deprecated
end
```

---

### #description

`#description(description = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L68)

Sets a detailed description for this action.

Used in generated exports as the operation description.
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L122)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L148)

Declares error codes this action may return.

Uses built-in error codes (:not_found, :forbidden, etc.) or custom codes
registered via ErrorCode.register. These appear in generated exports.

Multiple calls merge error codes (consistent with declaration merging).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error_code_keys` | `Array<Symbol>` | error code keys |

**See also**

- [ErrorCode](introspection-error-code)

**Example: Merging error codes**

```ruby
raises :not_found
raises :forbidden
# Result: [:not_found, :forbidden]
```

**Example**

```ruby
action :show do
  raises :not_found, :forbidden
end
```

---

### #request

`#request(replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L182)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[Request](contract-request) — the request definition

**See also**

- [Contract::Request](contract-request)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L216)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[Response](contract-response) — the response definition

**See also**

- [Contract::Response](contract-response)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L50)

Sets a short summary for this action.

Used in generated exports as the operation summary.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L85)

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
