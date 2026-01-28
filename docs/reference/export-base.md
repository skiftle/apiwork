---
order: 31
prev: false
next: false
---

# Export::Base

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L51)

The export name.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the export name to set |

**Returns**

`Symbol`, `nil`

---

### .file_extension

`.file_extension(value = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L122)

The file extension for string exports.

Only valid for exports with `output :string`. Hash exports derive
their extension from the format (:json becomes .json, :yaml becomes .yaml).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `String, nil` | the file extension (e.g., '.ts') |

**Returns**

`String`, `nil`

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L50)

Defines a configuration option.

For nested options, use `type: :hash` with a block. Inside the block,
call `option` to define child options.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | option name |
| `type` | `Symbol` | :symbol, :string, :integer, :boolean, or :hash |
| `default` | `Object, nil` | default value |
| `enum` | `Array, nil` | allowed values |

**Returns**

`void`

**See also**

- [Configuration::Option](configuration-option)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L60)

Declares the output type for this export.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | :hash for Hash output (json/yaml), :string for String output |

---

## Instance Methods

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L258)

The API introspection facade.

This is the primary interface for accessing introspection data in export generators.

**Returns**

[Introspection::API](introspection-api)

**See also**

- [Introspection::API](introspection-api)

---

### #generate

`#generate`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L236)

Generates the export output.

Override this method in subclasses to produce the export format.
Access API data via the [#data](#data) method which provides typed access
to types, enums, resources, actions, and other introspection data.

**Returns**

`Hash`, `String` — Hash for hash exports, String for string exports

**See also**

- [Introspection::API](introspection-api)

---

### #key_format

`#key_format`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L266)

The key format for this export.

**Returns**

`Symbol`

---

### #transform_key

`#transform_key(key)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/export/base.rb#L275)

Transforms a key according to the configured key format.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `String, Symbol` | the key to transform |

**Returns**

`String`

---
