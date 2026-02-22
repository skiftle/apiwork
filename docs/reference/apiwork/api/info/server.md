---
order: 7
prev: false
next: false
---

# Server

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L10)

Server definition block.

Used within the `server` block in [API::Info](/reference/apiwork/api/info/).

## Instance Methods

### #description

`#description(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L42)

The server description.

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
description 'Production'
server.description # => "Production"
```

---

### #url

`#url(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L26)

The server URL.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The URL. |

</div>

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://api.example.com'
server.url # => "https://api.example.com"
```

---
