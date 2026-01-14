---
order: 26
prev: false
next: false
---

# Export

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L5)

## Class Methods

### .find

`.find(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L33)

Finds an export by name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the export name |

**Returns**

[Export::Base](export-base), `nil` — the export class or nil if not found

**Example**

```ruby
Apiwork::Export.find(:openapi)
```

---

### .find!

`.find!(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L33)

Finds an export by name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the export name |

**Returns**

[Export::Base](export-base) — the export class

**Example**

```ruby
Apiwork::Export.find!(:openapi)
```

---

### .generate

`.generate(export_name, api_path, format: nil, key_format: nil, locale: nil, version: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L59)

Generates an export for an API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `export_name` | `Symbol` | the export name (:openapi, :typescript, :zod) |
| `api_path` | `String` | the API mount path |
| `format` | `Symbol` | output format (:json, :yaml) - only for data exports |
| `locale` | `Symbol, nil` | locale for translations (default: nil) |
| `key_format` | `Symbol, nil` | key casing (:camel, :underscore, :kebab, :keep) |
| `version` | `String, nil` | export version (export-specific) |

**Returns**

`String` — the generated export

**See also**

- [Export::Base](export-base)

**Example**

```ruby
Apiwork::Export.generate(:openapi, '/api/v1')
Apiwork::Export.generate(:openapi, '/api/v1', format: :yaml)
Apiwork::Export.generate(:typescript, '/api/v1', locale: :es, key_format: :camel)
```

---

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L33)

Registers an export.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | an [Export::Base](export-base) subclass with export_name set |

**See also**

- [Export::Base](export-base)

**Example**

```ruby
Apiwork::Export.register(JSONSchemaExport)
```

---
