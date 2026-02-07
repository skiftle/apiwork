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

The name for this license.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the license name (e.g. 'MIT', 'Apache 2.0') |

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

The URL for this license.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String` | the license URL |

**Returns**

`String`, `nil`

**Example**

```ruby
url 'https://opensource.org/licenses/MIT'
license.url  # => "https://opensource.org/licenses/MIT"
```

---
