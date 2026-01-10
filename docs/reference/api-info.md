---
order: 4
prev: false
next: false
---

# API::Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L10)

Defines API metadata.

Sets title, version, contact, license, and servers.
Used by export generators via [Export.generate](export#generate).

## Instance Methods

### #contact

`#contact(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L77)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L176)

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

`#description(description)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L149)

Sets a detailed description for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | `String` | the description (supports Markdown) |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L93)

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

`#server(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L118)

Adds a server to the API specification.

Can be called multiple times to define multiple servers.

**Returns**

`void`

**See also**

- [API::Info::Server](api-info-server)

**Example**

```ruby
info do
  server do
    url 'https://api.example.com'
    description 'Production'
  end
  server do
    url 'https://staging-api.example.com'
    description 'Staging'
  end
end
```

---

### #summary

`#summary(summary)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L135)

Sets a short summary for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `summary` | `String` | the summary |

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

`#tags(*tags)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L163)

Sets tags for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tags` | `Array<String>` | list of tags |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L62)

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

`#title(title)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L34)

Sets the API title.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `String` | the title |

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

`#version(version)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L48)

Sets the API version.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `version` | `String` | the version (e.g. '1.0.0') |

**Returns**

`void`

**Example**

```ruby
info do
  version '1.0.0'
end
```

---
