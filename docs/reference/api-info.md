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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L83)

Sets or gets contact information.

**Returns**

[Contact](api-info-contact), `void`

**See also**

- [API::Info::Contact](api-info-contact)

**Example**

```ruby
contact do
  name 'Support'
end
```

---

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L193)

Marks the API as deprecated.

**Returns**

`void`

**Example**

```ruby
info do
  deprecated!
end
```

---

### #description

`#description(description = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L162)

Sets or gets a detailed description for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | `String` | the description (supports Markdown) |

**Returns**

`String`, `void`

**Example**

```ruby
info do
  description 'Full-featured API for managing invoices and payments.'
end
```

---

### #license

`#license(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L101)

Sets or gets license information.

**Returns**

[License](api-info-license), `void`

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L128)

Adds a server or gets all servers.

Can be called multiple times to define multiple servers.

**Returns**

Array&lt;[Server](api-info-server)&gt;, `void`

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

`#summary(summary = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L146)

Sets or gets a short summary for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `summary` | `String` | the summary |

**Returns**

`String`, `void`

**Example**

```ruby
info do
  summary 'Invoice management API'
end
```

---

### #tags

`#tags(*values)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L178)

Sets or gets tags for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `values` | `Array<String>` | list of tags |

**Returns**

`Array<String>`, `void`

**Example**

```ruby
info do
  tags 'invoices', 'payments'
end
```

---

### #terms_of_service

`#terms_of_service(url = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L66)

Sets or gets the terms of service URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the terms of service URL |

**Returns**

`String`, `void`

**Example**

```ruby
info do
  terms_of_service 'https://example.com/terms'
end
```

---

### #title

`#title(title = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L34)

Sets or gets the API title.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `String` | the title |

**Returns**

`String`, `void`

**Example**

```ruby
info do
  title 'Invoice API'
end
```

---

### #version

`#version(version = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L50)

Sets or gets the API version.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `version` | `String` | the version (e.g. '1.0.0') |

**Returns**

`String`, `void`

**Example**

```ruby
info do
  version '1.0.0'
end
```

---
