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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L37)

Finds an export by name.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The export name. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L37)

Finds an export by name.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The export name. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L69)

Generates an export for an API.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`export_name`** | `Symbol` |  | The registered export name. Built-in: `:openapi`, `:typescript`, `:zod`. |
| **`api_path`** | `String` |  | The API path. |
| `format` | `Symbol<:json, :yaml>`, `nil` | `nil` | The output format. Hash exports only. |
| `locale` | `Symbol`, `nil` | `nil` | The locale for translations. |
| `key_format` | `Symbol<:camel, :kebab, :keep, :underscore>`, `nil` | `nil` | The key format. |
| **`options`** |  |  | Export-specific keyword arguments. |

</div>

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export.rb#L37)

Registers an export.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`klass`** | `Class<Export::Base>` |  | The export class with export_name set. |

</div>

**See also**

- [Export::Base](/reference/export/base)

**Example**

```ruby
Apiwork::Export.register(JSONSchemaExport)
```

---
