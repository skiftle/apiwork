---
order: 36
prev: false
next: false
---

# Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L10)

Defines request/response structure for an action.

Returns [Action::Request](/reference/contract/action/request) via `request` and [Action::Response](/reference/contract/action/response) via `response`.

## Modules

- [Request](./request)
- [Response](./response)

## Instance Methods

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L92)

Marks this action as deprecated.

**Returns**

`void`

**Example**

```ruby
action :legacy_create do
  deprecated!
end
```

---

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L100)

Whether this action is deprecated.

**Returns**

`Boolean`

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

`String`, `nil`

**Example**

```ruby
action :create do
  description 'Creates a new invoice and sends notification email.'
end
```

---

### #operation_id

`#operation_id(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L114)

Sets a custom operation ID for this action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | custom operation ID (optional) |

**Returns**

`String`, `nil`

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

Declares the raised error codes for this action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `error_code_keys` | `Symbol` | error code keys |

**Returns**

`void`

**Example**

```ruby
raises :not_found
raises :forbidden
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L186)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[Action::Request](/reference/contract/action/request)

**See also**

- [Action::Request](/reference/contract/action/request)

**Example: instance_eval style**

```ruby
action :create do
  request do
    query do
      boolean? :dry_run
    end
    body do
      string :title
    end
  end
end
```

**Example: yield style**

```ruby
action :create do
  request do |request|
    request.query do |query|
      query.boolean? :dry_run
    end
    request.body do |body|
      body.string :title
    end
  end
end
```

---

### #response

`#response(replace: false, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L233)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `replace` | `Boolean` | replace inherited definition (default: false) |

**Returns**

[Action::Response](/reference/contract/action/response)

**See also**

- [Action::Response](/reference/contract/action/response)

**Example: instance_eval style**

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

**Example: yield style**

```ruby
action :show do
  response do |response|
    response.body do |body|
      body.uuid :id
      body.string :title
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

`#summary(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L41)

Sets a short summary for this action.

Used in generated specs as the operation summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | summary text (optional) |

**Returns**

`String`, `nil`

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

`Array<Symbol>`, `nil`

**Example**

```ruby
action :create do
  tags :billing, :invoices
end
```

---
