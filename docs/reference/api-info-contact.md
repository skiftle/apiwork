---
order: 4
prev: false
next: false
---

# API::Info::Contact

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L10)

Defines contact information for the API.

Used within the `contact` block in [API::Info](api-info).

## Instance Methods

### #email

`#email(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L41)

Sets the contact email.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the contact email |

**Returns**

`void`

**Example**

```ruby
contact do
  email 'support@example.com'
end
```

---

### #name

`#name(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L27)

Sets the contact name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the contact name |

**Returns**

`void`

**Example**

```ruby
contact do
  name 'API Support'
end
```

---

### #url

`#url(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L55)

Sets the contact URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the contact URL |

**Returns**

`void`

**Example**

```ruby
contact do
  url 'https://example.com/support'
end
```

---
