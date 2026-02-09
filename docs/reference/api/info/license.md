---
order: 6
prev: false
next: false
---

# License

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L10)

License information block.

Used within the `license` block in [API::Info](/reference/api/info/).

## Instance Methods

### #name

`#name(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L25)

The license name.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
name 'MIT'
license.name  # => "MIT"
```

---

### #url

`#url(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L40)

The license URL.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` |  |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://opensource.org/licenses/MIT'
license.url  # => "https://opensource.org/licenses/MIT"
```

---
