---
order: 53
prev: false
next: false
---

# License

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/license.rb#L14)

Wraps API license information.

**Example**

```ruby
license = api.info.license
license.name  # => "MIT"
license.url   # => "https://opensource.org/licenses/MIT"
```

## Instance Methods

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/license.rb#L23)

The license name.

**Returns**

`String`, `nil`

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/license.rb#L39)

Converts this license to a hash.

**Returns**

`Hash`

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api/info/license.rb#L31)

The license URL.

**Returns**

`String`, `nil`

---
