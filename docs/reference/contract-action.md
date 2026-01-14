---
order: 17
prev: false
next: false
---

# Contract::Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L10)

Defines request/response structure for an action.

Returns [Request](contract-request) via `request` and [Response](contract-response) via `response`.

## Instance Methods

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L94)

Marks this action as deprecated.

Deprecated actions are flagged in generated specs.

**Returns**

`void`

**Example**

```ruby
action :legacy_create do
  deprecated!
end
```

---

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L60)

Sets a detailed description for this action.

Used in generated specs as the operation description.
Supports Markdown formatting.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | description text (optional) |

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

`#operation_id(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L108)

Sets a custom operation ID.

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

### #raises

`#raises(*error_code_keys)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L135)

Declares error codes this action may return.

Uses built-in error codes (:not_found, :forbidden, etc.) or custom codes
registered via ErrorCode.register. These appear in generated specs.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L173)

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
    query do
      boolean :dry_run, optional: true
    end
    body do
      string :title
    end
  end
end
```

---

### #response

`#response(replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L209)

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
      uuid :id
      string :title
    end
  end
end
```

**Example: No content response**

```ruby
action :destroy do
  response do
    no_content!
  end
end
```

---

### #summary

`#summary(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L41)

Sets a short summary for this action.

Used in generated specs as the operation summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | summary text (optional) |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L78)

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
