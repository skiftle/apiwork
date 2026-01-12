---
order: 7
prev: false
next: false
---

# API::Info::Server

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L10)

Server definition block.

Used within the `server` block in [API::Info](api-info).

## Instance Methods

### #description

`#description(description = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L40)

The server description.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
description 'Production'
server.description  # => "Production"
```

---

### #url

`#url(url = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L25)

The server URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://api.example.com'
server.url  # => "https://api.example.com"
```

---
