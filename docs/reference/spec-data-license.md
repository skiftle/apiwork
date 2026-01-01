---
order: 30
prev: false
next: false
---

# Spec::Data::License

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/license.rb#L13)

Wraps API license information.

**Example**

```ruby
license = data.info.license
license.name  # => "MIT"
license.url   # => "https://opensource.org/licenses/MIT"
```

## Instance Methods

### #name

`#name`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/license.rb#L20)

**Returns**

`String`, `nil` — license name

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/license.rb#L32)

**Returns**

`Hash` — structured representation

---

### #url

`#url`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data/license.rb#L26)

**Returns**

`String`, `nil` — license URL

---
