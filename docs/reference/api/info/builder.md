---
order: 4
prev: false
next: false
---

# Builder

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L6)

## Instance Methods

### #contact(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L46)

Defines contact information for OpenAPI spec.

**Example**

```ruby
info do
  contact do
    name 'API Support'
    email 'support@example.com'
    url 'https://example.com/support'
  end
end
```

---

### #deprecated(value = true)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L112)

Marks the entire API as deprecated.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Boolean` | deprecation status (default: true) |

---

### #description(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L98)

Sets a detailed API description for OpenAPI spec.

Supports Markdown formatting.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API description |

---

### #info()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L7)

Returns the value of attribute info.

---

### #initialize()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L9)

**Returns**

`Builder` — a new instance of Builder

---

### #license(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L63)

Defines license information for OpenAPI spec.

**Example**

```ruby
info do
  license do
    name 'MIT'
    url 'https://opensource.org/licenses/MIT'
  end
end
```

---

### #server(url:, description: = nil)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L81)

Adds a server URL to OpenAPI spec.

Multiple servers can be added by calling this method multiple times.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | server URL |
| `description` | `String` | server description (optional) |

**Example**

```ruby
info do
  server url: 'https://api.example.com', description: 'Production'
  server url: 'https://staging.example.com', description: 'Staging'
end
```

---

### #summary(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L89)

Sets a short API summary for OpenAPI spec.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API summary |

---

### #tags(*tags_list)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L105)

Sets default tags for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags_list` | `Array<String,Symbol>` | tag names |

---

### #terms_of_service(url)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L30)

Sets the terms of service URL for OpenAPI spec.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | URL to terms of service |

---

### #title(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L16)

Sets the API title for OpenAPI spec.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API title |

---

### #version(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L23)

Sets the API version for OpenAPI spec.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API version (e.g., '1.0.0') |

---
