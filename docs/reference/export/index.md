---
order: 47
prev: false
next: false
---

# Export

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L6)

Namespace for export generators and the export registry.

## Modules

- [Base](./base)

## Class Methods

### .find

`.find(name)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L34)

Finds an export by name.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the export name |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L34)

Finds an export by name.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol` |  | the export name |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L60)

Generates an export for an API.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `export_name` | `Symbol` |  | the export name (:openapi, :typescript, :zod) |
| `api_path` | `String` |  | the API path |
| `format` | `Symbol` |  | output format (:json, :yaml) - hash exports only |
| `locale` | `Symbol`, `nil` | `nil` | locale for translations |
| `key_format` | `Symbol<:camel, :underscore, :kebab, :keep>`, `nil` | `nil` |  |
| `options` |  |  | export-specific keyword arguments |

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L34)

Registers an export.

**Parameters**

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `klass` | `Class<Export::Base>` |  | the export class with export_name set |

**See also**

- [Export::Base](/reference/export/base)

**Example**

```ruby
Apiwork::Export.register(JSONSchemaExport)
```

---
