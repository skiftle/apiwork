---
order: 5
prev: false
next: false
---

# API::InfoBuilder::LicenseBuilder

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/license_builder.rb#L10)

Defines license information for the API.

Used within the `license` block in [API::InfoBuilder](api-info-builder).

## Instance Methods

### #name

`#name(text)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/license_builder.rb#L27)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/api/info_builder/license_builder.rb#L41)

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
