---
order: 4
prev: false
next: false
---

# API::Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L9)

API info block.

Used within the `info` block in [API::Base](api-base).

## Instance Methods

### #contact

`#contact(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L80)

Contact information.

**Returns**

[Contact](api-info-contact), `nil`

**See also**

- [API::Info::Contact](api-info-contact)

**Example**

```ruby
contact do
  name 'Support'
end
info.contact.name  # => "Support"
```

---

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L183)

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

### #deprecated?

`#deprecated?`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L194)

Whether the API is deprecated.

**Returns**

`Boolean`

**Example**

```ruby
info.deprecated?  # => true
```

---

### #description

`#description(description = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L153)

A detailed description.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | `String` | supports Markdown |

**Returns**

`String`, `nil`

**Example**

```ruby
description 'Full-featured API for managing invoices and payments.'
info.description  # => "Full-featured..."
```

---

### #license

`#license(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L99)

License information.

**Returns**

[License](api-info-license), `nil`

**See also**

- [API::Info::License](api-info-license)

**Example**

```ruby
license do
  name 'MIT'
end
info.license.name  # => "MIT"
```

---

### #server

`#server(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L121)

Server definitions.

Can be called multiple times to define multiple servers.

**Returns**

Array&lt;[Server](api-info-server)&gt;

**See also**

- [API::Info::Server](api-info-server)

**Example**

```ruby
server do
  url 'https://api.example.com'
  description 'Production'
end
info.server  # => [#<Server ...>]
```

---

### #summary

`#summary(summary = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L138)

A short summary.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `summary` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
summary 'Invoice management API'
info.summary  # => "Invoice management API"
```

---

### #tags

`#tags(*values)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L168)

Tags for the API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `values` | `Array<String>` |  |

**Returns**

`Array<String>`

**Example**

```ruby
tags 'invoices', 'payments'
info.tags  # => ["invoices", "payments"]
```

---

### #terms_of_service

`#terms_of_service(url = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L62)

The terms of service URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
terms_of_service 'https://example.com/terms'
info.terms_of_service  # => "https://example.com/terms"
```

---

### #title

`#title(title = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L32)

The API title.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
title 'Invoice API'
info.title  # => "Invoice API"
```

---

### #version

`#version(version = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L47)

The API version.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `version` | `String` | e.g. '1.0.0' |

**Returns**

`String`, `nil`

**Example**

```ruby
version '1.0.0'
info.version  # => "1.0.0"
```

---
