---
order: 20
prev: false
next: false
---

# Introspection::API

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L23)

Facade for introspected API data.

Entry point for accessing all API data. Access resources via [#resources](#resources),
types via [#types](#types), enums via [#enums](#enums).

**Example**

```ruby
api = Apiwork::API.introspect('/api/v1', locale: :fr)

api.info.title                      # => "Mon API"
api.types[:address].description     # => "Type d'adresse"
api.enums[:status].values           # => ["draft", "published"]

api.resources.each_value do |resource|
  resource.actions.each_value do |action|
    # ...
  end
end
```

## Instance Methods

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L58)

**Returns**

`Hash{Symbol => Enum}` — registered enums

**See also**

- [Enum](introspection-enum)

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L71)

**Returns**

`Hash{Symbol => ErrorCode}` — error code definitions

**See also**

- [ErrorCode](introspection-error-code)

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L37)

**Returns**

`API::Info` — API metadata

**See also**

- [API::Info](api-info)

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L30)

**Returns**

[String](introspection-string), `nil` — API mount path (e.g., "/api/v1")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L64)

**Returns**

`Array<Symbol>` — API-level error codes that may be raised

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L44)

**Returns**

`Hash{Symbol => API::Resource}` — top-level resources

**See also**

- [API::Resource](api-resource)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L77)

**Returns**

`Hash` — structured representation

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/introspection/api.rb#L51)

**Returns**

`Hash{Symbol => Type}` — registered custom types

**See also**

- [Type](introspection-type)

---
