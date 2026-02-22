---
order: 4
prev: false
next: false
---

# Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L9)

Block context for defining API metadata.

Used within the `info` block in [API::Base](/reference/apiwork/api/base).

## Modules

- [Contact](./contact)
- [License](./license)
- [Server](./server)

## Instance Methods

### #contact

`#contact(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L89)

The API contact.

**Returns**

[Contact](/reference/apiwork/api/info/contact), `nil`

**Yields** [Contact](/reference/apiwork/api/info/contact)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L208)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L216)

Whether the API is deprecated.

**Returns**

`Boolean`

---

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L177)

The API description.

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
description 'Full-featured API for managing invoices and payments.'
info.description # => "Full-featured..."
```

---

### #license

`#license(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L115)

The API license.

**Returns**

[License](/reference/apiwork/api/info/license), `nil`

**Yields** [License](/reference/apiwork/api/info/license)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L143)

Defines a server for the API.

Can be called multiple times.

**Returns**

Array&lt;[Server](/reference/apiwork/api/info/server)&gt;

**Yields** [Server](/reference/apiwork/api/info/server)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L161)

The API summary.

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
summary 'Invoice management API'
info.summary # => "Invoice management API"
```

---

### #tags

`#tags(*values)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L193)

The API tags.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`values`** | `Array<String>` |  | The tags. |

</div>

**Returns**

`Array<String>`

**Example**

```ruby
tags 'invoices', 'payments'
info.tags # => ["invoices", "payments"]
```

---

### #terms_of_service

`#terms_of_service(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L65)

The API terms of service.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The URL to terms of service. |

</div>

**Returns**

`String`, `nil`

**Example**

```ruby
terms_of_service 'https://example.com/terms'
info.terms_of_service # => "https://example.com/terms"
```

---

### #title

`#title(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L33)

The API title.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The title. |

</div>

**Returns**

`String`, `nil`

**Example**

```ruby
title 'Invoice API'
info.title # => "Invoice API"
```

---

### #version

`#version(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info.rb#L49)

The API version.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The version. |

</div>

**Returns**

`String`, `nil`

**Example**

```ruby
version '1.0.0'
info.version # => "1.0.0"
```

---
