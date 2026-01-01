---
order: 4
prev: false
next: false
---

# API::InfoBuilder::ContactBuilder

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/contact_builder.rb#L10)

Defines contact information for the API.

Used within the `contact` block in [API::InfoBuilder](api-info-builder).

## Instance Methods

### #email

`#email(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/contact_builder.rb#L41)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/contact_builder.rb#L27)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/contact_builder.rb#L55)

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
