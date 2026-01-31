---
order: 38
prev: false
next: false
---

# Introspection::API::Info::Server

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L28)

**Returns**

`String`, `nil` — server description

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L34)

**Returns**

`Hash` — structured representation

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/server.rb#L22)

**Returns**

`String`, `nil` — server URL

---
