---
order: 35
prev: false
next: false
---

# Spec::Data::Server

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/server.rb#L14)

Wraps API server information.

**Example**

```ruby
data.info.servers.each do |server|
  puts server.url          # => "https://api.example.com"
  puts server.description  # => "Production server"
end
```

## Instance Methods

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/server.rb#L27)

**Returns**

`String`, `nil` — server description

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/server.rb#L33)

**Returns**

`Hash` — structured representation

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/server.rb#L21)

**Returns**

`String`, `nil` — server URL

---
