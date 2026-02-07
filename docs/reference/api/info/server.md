---
order: 7
prev: false
next: false
---

# Server

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L10)

Server definition block.

Used within the `server` block in [API::Info](/reference/api/info/).

## Instance Methods

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L40)

The description for this server.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the server description |

**Returns**

`String`, `nil`

**Example**

```ruby
description 'Production'
server.description  # => "Production"
```

---

### #url

`#url(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L25)

The URL for this server.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the server URL |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://api.example.com'
server.url  # => "https://api.example.com"
```

---
