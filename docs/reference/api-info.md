---
order: 3
prev: false
next: false
---

# API::Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L10)

Defines API metadata.

Sets title, version, contact, license, and servers.
Used by spec generators via [Spec.generate](spec#generate).

## Instance Methods

### #contact

`#contact(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L70)

Defines contact information.

**Returns**

`void`

**See also**

- [API::Info::Contact](api-info-contact)

**Example**

```ruby
contact do
  name 'Support'
end
```

---

### #deprecated

`#deprecated`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L161)

Marks the API as deprecated.

**Returns**

`void`

**Example**

```ruby
info do
  deprecated
end
```

---

### #description

`#description(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L134)

Sets a detailed description for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the description (supports Markdown) |

**Returns**

`void`

**Example**

```ruby
info do
  description 'Full-featured API for managing invoices and payments.'
end
```

---

### #license

`#license(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L87)

Defines license information.

**Returns**

`void`

**See also**

- [API::Info::License](api-info-license)

**Example**

```ruby
license do
  name 'MIT'
end
```

---

### #server

`#server(description: nil, url:)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L105)

Adds a server to the API specification.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the server URL |
| `description` | `String, nil` | optional server description |

**Returns**

`void`

**Example**

```ruby
info do
  server url: 'https://api.example.com', description: 'Production'
  server url: 'https://staging-api.example.com', description: 'Staging'
end
```

---

### #summary

`#summary(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L120)

Sets a short summary for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the summary |

**Returns**

`void`

**Example**

```ruby
info do
  summary 'Invoice management API'
end
```

---

### #tags

`#tags(*tags_list)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L148)

Sets tags for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags_list` | `Array<String>` | list of tags |

**Returns**

`void`

**Example**

```ruby
info do
  tags 'invoices', 'payments'
end
```

---

### #terms_of_service

`#terms_of_service(url)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L55)

Sets the terms of service URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the terms of service URL |

**Returns**

`void`

**Example**

```ruby
info do
  terms_of_service 'https://example.com/terms'
end
```

---

### #title

`#title(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L27)

Sets the API title.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the title |

**Returns**

`void`

**Example**

```ruby
info do
  title 'Invoice API'
end
```

---

### #version

`#version(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L41)

Sets the API version.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the version (e.g. '1.0.0') |

**Returns**

`void`

**Example**

```ruby
info do
  version '1.0.0'
end
```

---
