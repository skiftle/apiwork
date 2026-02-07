---
order: 51
prev: false
next: false
---

# Server

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L15)

Wraps API server information.

**Example**

```ruby
api.info.servers.each do |server|
  puts server.url          # => "https://api.example.com"
  puts server.description  # => "Production server"
end
```

## Instance Methods

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L32)

The server description.

**Returns**

`String`, `nil`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L40)

Converts this server to a hash.

**Returns**

`Hash`

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L24)

The server URL.

**Returns**

`String`, `nil`

---
