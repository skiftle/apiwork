---
order: 3
prev: false
next: false
---

# Builder

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L6)

## Instance Methods

### #contact(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L47)

Defines contact information.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L113)

Marks the entire API as deprecated.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `Boolean` | deprecation status (default: true) |

---

### #description(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L99)

Sets a detailed API description.

Supports Markdown formatting.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API description |

---

### #license(&block)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L64)

Defines license information.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L82)

Adds a server URL.

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L90)

Sets a short API summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API summary |

---

### #tags(*tags_list)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L106)

Sets default tags for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags_list` | `Array<String,Symbol>` | tag names |

---

### #terms_of_service(url)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L31)

Sets the terms of service URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | URL to terms of service |

---

### #title(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L17)

Sets the API title.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API title |

---

### #version(text)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/builder.rb#L24)

Sets the API version.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | API version (e.g., '1.0.0') |

---
