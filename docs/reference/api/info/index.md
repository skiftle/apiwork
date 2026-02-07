---
order: 4
prev: false
next: false
---

# Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L9)

API info block.

Used within the `info` block in [API::Base](/reference/api/base).

## Modules

- [Contact](./contact)
- [License](./license)
- [Server](./server)

## Instance Methods

### #contact

`#contact(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L80)

The contact for this info.

**Returns**

[Contact](/reference/api/info/contact), `nil`

**See also**

- [API::Info::Contact](/reference/api/info/contact)

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

Whether this API is deprecated.

**Returns**

`Boolean`

**Example**

```ruby
info.deprecated?  # => true
```

---

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L153)

The description for this info.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the description (supports Markdown) |

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

The license for this info.

**Returns**

[License](/reference/api/info/license), `nil`

**See also**

- [API::Info::License](/reference/api/info/license)

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

The server definitions for this info.

Can be called multiple times to define multiple servers.

**Returns**

Array&lt;[Server](/reference/api/info/server)&gt;

**See also**

- [API::Info::Server](/reference/api/info/server)

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

`#summary(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L138)

The summary for this info.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the summary |

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

The tags for this info.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `values` | `Array<String>` | the tags |

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

The terms of service for this info.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the terms of service URL |

**Returns**

`String`, `nil`

**Example**

```ruby
terms_of_service 'https://example.com/terms'
info.terms_of_service  # => "https://example.com/terms"
```

---

### #title

`#title(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L32)

The title for this info.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the title |

**Returns**

`String`, `nil`

**Example**

```ruby
title 'Invoice API'
info.title  # => "Invoice API"
```

---

### #version

`#version(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L47)

The version for this info.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the version (e.g. '1.0.0') |

**Returns**

`String`, `nil`

**Example**

```ruby
version '1.0.0'
info.version  # => "1.0.0"
```

---
