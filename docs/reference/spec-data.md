---
order: 24
prev: false
next: false
---

# Spec::Data

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L28)

Wraps introspection data for spec generators.

Entry point for accessing all API data in a spec generator.
Access resources via [#resources](#resources), types via [#types](#types), enums via [#enums](#enums).

**Example**

```ruby
data = Spec::Data.new(introspection_data)

data.info.title              # => "My API"
data.types.each { |t| ... }  # iterate custom types
data.enums.each { |e| ... }  # iterate enums

data.each_resource do |resource, parent_path|
  resource.actions.each do |action|
    # ...
  end
end
```

## Instance Methods

### #each_resource

`#each_resource(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L94)

Iterates over all resources recursively (including nested).

**See also**

- [Data::Resource](spec-data-resource)

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L67)

**Returns**

`Array<Data::Enum>` — registered enums

**See also**

- [Data::Enum](spec-data-enum)

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L82)

**Returns**

`Array<Data::ErrorCode>` — error code definitions

**See also**

- [Data::ErrorCode](spec-data-error-code)

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L42)

**Returns**

`Data::Info` — API metadata

**See also**

- [Data::Info](spec-data-info)

---

### #path

`#path`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L35)

**Returns**

`String`, `nil` — API mount path (e.g., "/api/v1")

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L75)

**Returns**

`Array<Symbol>` — API-level error codes that may be raised

---

### #resources

`#resources`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L49)

**Returns**

`Array<Data::Resource>` — top-level resources

**See also**

- [Data::Resource](spec-data-resource)

---

### #to_h

`#to_h`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L100)

**Returns**

`Hash` — structured representation

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/data.rb#L58)

**Returns**

`Array<Data::Type>` — registered custom types

**See also**

- [Data::Type](spec-data-type)

---
