---
order: 48
prev: false
next: false
---

# Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L34)

Base class for exports.

Subclass this to create custom export formats. Declare output type
and override `#generate` to produce output.

**Example: Hash export (supports json/yaml)**

```ruby
class OpenAPI < Apiwork::Export::Base
  export_name :openapi
  output :hash

  def generate
    { openapi: '3.1.0', ... }  # Returns Hash
  end
end
```

**Example: String export (fixed format)**

```ruby
class ProtobufExport < Apiwork::Export::Base
  export_name :protobuf
  output :string
  file_extension '.proto'

  def generate
    "syntax = \"proto3\";\n..."  # Returns String
  end
end

# Register the export
Apiwork::Export.register(ProtobufExport)
```

## Class Methods

### .export_name

`.export_name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L59)

The name for this export.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `Symbol`, `nil` | `nil` | The export name. |

</div>

**Returns**

`Symbol`, `nil`

---

### .file_extension

`.file_extension(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L86)

The file extension for this export.

Only applies to string exports. Hash exports derive extension from format.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String`, `nil` | `nil` | The file extension (e.g., '.ts'). |

</div>

**Returns**

`String`, `nil`

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L56)

Defines a configuration option.

For nested options, use `type: :hash` with a block. Inside the block,
call `option` to define child options.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`name`** | `Symbol` |  | The option name. |
| **`type`** | `Symbol<:boolean, :hash, :integer, :string, :symbol>` |  | The option type. |
| `default` | `Object`, `nil` | `nil` | The default value. |
| `enum` | `Array`, `nil` | `nil` | The allowed values. |

</div>

**Returns**

`void`

**See also**

- [Configuration::Option](/reference/apiwork/configuration/option)

**Example: Symbol option**

```ruby
option :locale, type: :symbol, default: :en
```

**Example: String option with enum**

```ruby
option :version, type: :string, default: '5', enum: %w[4 5]
```

**Example: Nested options**

```ruby
option :pagination, type: :hash do
  option :strategy, type: :symbol, default: :offset, enum: %i[offset cursor]
  option :default_size, type: :integer, default: 20
  option :max_size, type: :integer, default: 100
end
```

---

### .output

`.output(type = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L70)

The output for this export.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `type` | `Symbol<:hash, :string>`, `nil` | `nil` | The output type. :hash for Hash output (json/yaml), :string for String output. |

</div>

**Returns**

`Symbol`, `nil`

---

## Instance Methods

### #api

`#api`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L48)

The API introspection for this export.

Primary interface for accessing introspection data in export generators.

**Returns**

[Introspection::API](/reference/apiwork/introspection/api/)

**See also**

- [Introspection::API](/reference/apiwork/introspection/api/)

---

### #generate

`#generate`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L232)

Generates the export output.

Override this method in subclasses to produce the export format.
Access API data via the [#api](#api) method which provides typed access
to types, enums, resources, actions, and other introspection data.

**Returns**

`Hash`, `String`

**See also**

- [Introspection::API](/reference/apiwork/introspection/api/)

---

### #key_format

`#key_format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L240)

The key format for this export.

**Returns**

`Symbol`

---

### #transform_key

`#transform_key(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L251)

Transforms a key according to the configured key format.

**Parameters**

<div class="params-table">

| Name | Type | Default | Description |
|------|------|---------|-------------|
| **`key`** | `String`, `Symbol` |  | The key to transform. |

</div>

**Returns**

`String`

**See also**

- [#key_format](#key-format)

---
