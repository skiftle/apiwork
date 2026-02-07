---
order: 48
prev: false
next: false
---

# Info

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L16)

Wraps API metadata/info.

**Example**

```ruby
info = api.info
info.title            # => "My API"
info.version          # => "1.0.0"
info.description      # => "API for managing resources"
info.contact&.email   # => "support@example.com"
info.license&.name    # => "MIT"
```

## Modules

- [Contact](./contact)
- [License](./license)
- [Server](./server)

## Instance Methods

### #contact

`#contact`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L66)

The API contact.

**Returns**

[Info::Contact](/reference/api/info/contact), `nil`

**See also**

- [Info::Contact](/reference/api/info/contact)

---

### #description

`#description`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L41)

The API description.

**Returns**

`String`, `nil`

---

### #license

`#license`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L75)

The API license.

**Returns**

[Info::License](/reference/api/info/license), `nil`

**See also**

- [Info::License](/reference/api/info/license)

---

### #servers

`#servers`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L84)

The API servers.

**Returns**

Array&lt;[Info::Server](/reference/api/info/server)&gt;

**See also**

- [Info::Server](/reference/api/info/server)

---

### #summary

`#summary`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L49)

The API summary.

**Returns**

`String`, `nil`

---

### #terms_of_service

`#terms_of_service`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L57)

The API terms of service.

**Returns**

`String`, `nil`

---

### #title

`#title`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L25)

The API title.

**Returns**

`String`, `nil`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L92)

Converts this info to a hash.

**Returns**

`Hash`

---

### #version

`#version`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info.rb#L33)

The API version.

**Returns**

`String`, `nil`

---
