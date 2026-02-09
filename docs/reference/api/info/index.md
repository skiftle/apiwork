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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L86)

The API contact.

**Returns**

[Contact](/reference/api/info/contact), `nil`

**Yields** [Contact](/reference/api/info/contact)

**Example: instance_eval style**

```ruby
contact do
  name 'Support'
  email 'support@example.com'
end
```

**Example: yield style**

```ruby
contact do |contact|
  contact.name 'Support'
  contact.email 'support@example.com'
end
```

---

### #deprecated!

`#deprecated!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L202)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L210)

Whether the API is deprecated.

**Returns**

`Boolean`

---

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L172)

The API description.

**Parameters**

| Name | Type |
|------|------|
| `value` | `String, nil` |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L112)

The API license.

**Returns**

[License](/reference/api/info/license), `nil`

**Yields** [License](/reference/api/info/license)

**Example: instance_eval style**

```ruby
license do
  name 'MIT'
  url 'https://opensource.org/licenses/MIT'
end
```

**Example: yield style**

```ruby
license do |license|
  license.name 'MIT'
  license.url 'https://opensource.org/licenses/MIT'
end
```

---

### #server

`#server(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L140)

Defines a server for the API.

Can be called multiple times.

**Returns**

Array&lt;[Server](/reference/api/info/server)&gt;

**Yields** [Server](/reference/api/info/server)

**Example: instance_eval style**

```ruby
server do
  url 'https://api.example.com'
  description 'Production'
end
```

**Example: yield style**

```ruby
server do |server|
  server.url 'https://api.example.com'
  server.description 'Production'
end
```

---

### #summary

`#summary(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L157)

The API summary.

**Parameters**

| Name | Type |
|------|------|
| `value` | `String, nil` |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L187)

The API tags.

**Parameters**

| Name | Type |
|------|------|
| `values` | `Array<String>` |

**Returns**

`Array<String>`

**Example**

```ruby
tags 'invoices', 'payments'
info.tags  # => ["invoices", "payments"]
```

---

### #terms_of_service

`#terms_of_service(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L62)

The API terms of service.

**Parameters**

| Name | Type |
|------|------|
| `value` | `String, nil` |

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

The API title.

**Parameters**

| Name | Type |
|------|------|
| `value` | `String, nil` |

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

The API version.

**Parameters**

| Name | Type |
|------|------|
| `value` | `String, nil` |

**Returns**

`String`, `nil`

**Example**

```ruby
version '1.0.0'
info.version  # => "1.0.0"
```

---
