---
order: 22
prev: false
next: false
---

# Export

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L5)

## Class Methods

### .generate

`.generate(export_name, api_path, format: nil, key_format: nil, locale: nil, version: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L38)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L14)

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
