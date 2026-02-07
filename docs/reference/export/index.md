---
order: 45
prev: false
next: false
---

# Export

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L5)

## Modules

- [Base](./base)

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

Class&lt;[Export::Base](/reference/export/base)&gt;, `nil`

**See also**

- [.find!](#find!)

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

Class&lt;[Export::Base](/reference/export/base)&gt;

**See also**

- [.find](#find)

**Example**

```ruby
Apiwork::Export.find!(:openapi)
```

---

### .generate

`.generate(export_name, api_path, format: nil, key_format: nil, locale: nil, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L59)

Generates an export for an API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `export_name` | `Symbol` | the export name (:openapi, :typescript, :zod) |
| `api_path` | `String` | the API path |
| `format` | `Symbol` | output format (:json, :yaml) - hash exports only |
| `locale` | `Symbol, nil` | locale for translations |
| `key_format` | `Symbol, nil` | key casing (:camel, :underscore, :kebab, :keep) |
| `options` | `` | export-specific keyword arguments |

**Returns**

`String`

**See also**

- [Export::Base](/reference/export/base)

**Example**

```ruby
Apiwork::Export.generate(:openapi, '/api/v1')
Apiwork::Export.generate(:openapi, '/api/v1', format: :yaml)
Apiwork::Export.generate(:typescript, '/api/v1', key_format: :camel)
```

---

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L33)

Registers an export.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class<Export::Base>` | the export class with export_name set |

**See also**

- [Export::Base](/reference/export/base)

**Example**

```ruby
Apiwork::Export.register(JSONSchemaExport)
```

---
