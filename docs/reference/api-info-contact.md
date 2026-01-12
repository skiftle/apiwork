---
order: 5
prev: false
next: false
---

# API::Info::Contact

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L10)

Defines contact information for the API.

Used within the `contact` block in [API::Info](api-info).

## Instance Methods

### #email

`#email(email = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L43)

Sets or gets the contact email.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `email` | `String` | the contact email |

**Returns**

`String`, `void`

**Example**

```ruby
contact do
  email 'support@example.com'
end
```

---

### #name

`#name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L27)

Sets or gets the contact name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `String` | the contact name |

**Returns**

`String`, `void`

**Example**

```ruby
contact do
  name 'API Support'
end
```

---

### #url

`#url(url = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L59)

Sets or gets the contact URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the contact URL |

**Returns**

`String`, `void`

**Example**

```ruby
contact do
  url 'https://example.com/support'
end
```

---
