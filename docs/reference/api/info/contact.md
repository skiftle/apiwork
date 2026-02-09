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

The contact email.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` |  |  |

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

The contact name.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` |  |  |

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

The contact URL.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` |  |  |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://example.com/support'
contact.url  # => "https://example.com/support"
```

---
