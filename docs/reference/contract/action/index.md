---
order: 37
prev: false
next: false
---

# Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L9)

Defines request/response structure for an action.

Returns [Action::Request](/reference/contract/action/request) via `request` and [Action::Response](/reference/contract/action/response) via `response`.

## Modules

- [Request](./request)
- [Response](./response)

## Instance Methods

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L91)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L99)

Whether this action is deprecated.

**Returns**

`Boolean`

---

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L59)

The description for this action.

Used in generated specs as the operation description.
Supports Markdown formatting.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | description text |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L113)

The operation ID for this action.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | custom operation ID |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L134)

Declares the raised error codes for this action.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `error_code_keys` | `Symbol` |  | error code keys |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L184)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `replace` | `Boolean` | `false` | replace inherited definition |

**Returns**

[Action::Request](/reference/contract/action/request)

**Yields** [Action::Request](/reference/contract/action/request)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L230)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `replace` | `Boolean` | `false` | replace inherited definition |

**Returns**

[Action::Response](/reference/contract/action/response)

**Yields** [Action::Response](/reference/contract/action/response)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L40)

The summary for this action.

Used in generated specs as the operation summary.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | summary text |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L77)

The tags for this action.

Tags help organize actions in generated documentation.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `Array<String,Symbol>` |  | tag names |

**Returns**

`Array<Symbol>`, `nil`

**Example**

```ruby
action :create do
  tags :billing, :invoices
end
```

---
