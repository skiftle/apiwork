---
order: 5
prev: false
next: false
---

# API::Info::Contact

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L10)

Contact information block.

Used within the `contact` block in [API::Info](api-info).

## Instance Methods

### #email

`#email(email = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L41)

The contact email.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `email` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
email 'support@example.com'
contact.email  # => "support@example.com"
```

---

### #name

`#name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L26)

The contact name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
name 'API Support'
contact.name  # => "API Support"
```

---

### #url

`#url(url = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L56)

The contact URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://example.com/support'
contact.url  # => "https://example.com/support"
```

---
