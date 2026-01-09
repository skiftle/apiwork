---
order: 6
prev: false
next: false
---

# API::Info::Server

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L10)

Defines server information for the API.

Used within the `server` block in [API::Info](api-info).

## Instance Methods

### #description

`#description(description)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L47)

Sets the server description.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | `String` | the server description |

**Returns**

`void`

**Example**

```ruby
server do
  description 'Production'
end
```

---

### #url

`#url(url)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/server.rb#L33)

Sets the server URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the server URL |

**Returns**

`void`

**Example**

```ruby
server do
  url 'https://api.example.com'
end
```

---
