---
order: 6
prev: false
next: false
---

# API::Info::License

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L10)

Defines license information for the API.

Used within the `license` block in [API::Info](api-info).

## Instance Methods

### #name

`#name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L26)

Sets or gets the license name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `String` | the license name (e.g. 'MIT', 'Apache 2.0') |

**Returns**

`String`, `void`

**Example**

```ruby
license do
  name 'MIT'
end
```

---

### #url

`#url(url = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L42)

Sets or gets the license URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | `String` | the license URL |

**Returns**

`String`, `void`

**Example**

```ruby
license do
  url 'https://opensource.org/licenses/MIT'
end
```

---
