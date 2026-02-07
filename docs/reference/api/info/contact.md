---
order: 5
prev: false
next: false
---

# Contact

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L10)

Contact information block.

Used within the `contact` block in [API::Info](/reference/api/info/).

## Instance Methods

### #email

`#email(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L41)

The email for this contact.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the contact email |

**Returns**

`String`, `nil`

**Example**

```ruby
email 'support@example.com'
contact.email  # => "support@example.com"
```

---

### #name

`#name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L26)

The name for this contact.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the contact name |

**Returns**

`String`, `nil`

**Example**

```ruby
name 'API Support'
contact.name  # => "API Support"
```

---

### #url

`#url(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/contact.rb#L56)

The URL for this contact.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the contact URL |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://example.com/support'
contact.url  # => "https://example.com/support"
```

---
