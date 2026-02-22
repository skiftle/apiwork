---
order: 37
prev: false
next: false
---

# Action

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L9)

Defines request/response structure for an action.

Returns [Action::Request](/reference/apiwork/contract/action/request) via `request` and [Action::Response](/reference/apiwork/contract/action/response) via `response`.

## Modules

- [Request](./request)
- [Response](./response)

## Instance Methods

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L94)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L102)

Whether this action is deprecated.

**Returns**

`Boolean`

---

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L61)

The description for this action.

Used in generated specs as the operation description.
Supports Markdown formatting.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The description. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L117)

The operation ID for this action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The operation ID. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L139)

Declares the raised error codes for this action.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`error_code_keys`** | `Symbol` |  | The error code keys. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L190)

Defines the request structure for this action.

Use the block to define query parameters and request body.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `replace` | `Boolean` | `false` | Whether to replace inherited definition. |

</div>

**Returns**

[Action::Request](/reference/apiwork/contract/action/request)

**Yields** [Action::Request](/reference/apiwork/contract/action/request)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L237)

Defines the response structure for this action.

Use the block to define response body or declare no_content.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `replace` | `Boolean` | `false` | Whether to replace inherited definition. |

</div>

**Returns**

[Action::Response](/reference/apiwork/contract/action/response)

**Yields** [Action::Response](/reference/apiwork/contract/action/response)

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

The summary for this action.

Used in generated specs as the operation summary.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The summary. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/contract/action.rb#L80)

The tags for this action.

Tags help organize actions in generated documentation.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`tags`** | `Array<String, Symbol>` |  | The tag names. |

</div>

**Returns**

`Array<Symbol>`, `nil`

**Example**

```ruby
action :create do
  tags :billing, :invoices
end
```

---
