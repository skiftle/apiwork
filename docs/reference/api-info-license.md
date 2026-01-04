---
order: 5
prev: false
next: false
---

# API::Info::License

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L10)

Defines license information for the API.

Used within the `license` block in [API::Info](api-info).

## Instance Methods

### #name

`#name(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L27)

Sets the license name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the license name (e.g. 'MIT', 'Apache 2.0') |

**Returns**

`void`

**Example**

```ruby
license do
  name 'MIT'
end
```

---

### #url

`#url(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info/license.rb#L41)

Sets the license URL.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | `String` | the license URL |

**Returns**

`void`

**Example**

```ruby
license do
  url 'https://opensource.org/licenses/MIT'
end
```

---
