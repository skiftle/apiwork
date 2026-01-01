---
order: 23
prev: false
next: false
---

# Spec::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L34)

Base class for spec generators.

Subclass this to create custom spec formats. Declare output type
and override `#generate` to produce output.

**Example: Data spec (supports json/yaml)**

```ruby
class OpenAPISpec < Apiwork::Spec::Base
  spec_name :openapi
  output :data

  def generate
    { openapi: '3.1.0', ... }  # Returns Hash
  end
end
```

**Example: Text spec (fixed format)**

```ruby
class ProtobufSpec < Apiwork::Spec::Base
  spec_name :protobuf
  output :text
  file_extension '.proto'

  def generate
    "syntax = \"proto3\";\n..."  # Returns String
  end
end

# Register the spec
Apiwork::Spec.register(ProtobufSpec)
```

## Class Methods

### .file_extension

`.file_extension(file_extension = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L103)

Sets the file extension for text specs.

Only valid for specs with `output :text`. Data specs derive
their extension from the format (:json → .json, :yaml → .yaml).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file_extension` | `String, nil` | the file extension (e.g., '.ts') |

**Returns**

`String`, `nil` — the file extension

---

### .generate

`.generate(api_path, format: nil, key_format: nil, locale: nil, version: nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L80)

Generates a spec for the given API path.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `api_path` | `String` | the API mount path |
| `format` | `Symbol` | output format (:json, :yaml) - only for data specs |
| `locale` | `Symbol, nil` | locale for translations (default: nil) |
| `key_format` | `Symbol, nil` | key casing (:camel, :underscore, :kebab, :keep) |
| `version` | `String, nil` | spec version (default varies by spec) |

**Returns**

`String` — the generated spec

**See also**

- [API::Base](api-base)

---

### .option

`.option(name, type:, default: nil, enum: nil, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/configurable.rb#L31)

Defines a configuration option for the spec or adapter.

Options can be passed to `.generate` or set via environment variables.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol` | the option name |
| `type` | `Symbol` | the option type (:symbol, :string, :boolean, :integer) |
| `default` | `Object, nil` | default value if not provided |
| `enum` | `Array, nil` | allowed values |

**Returns**

`void`

**Example: Simple option**

```ruby
option :locale, type: :symbol, default: :en
```

**Example: Option with enum**

```ruby
option :format, type: :symbol, enum: [:json, :yaml]
```

---

### .output

`.output(type = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L52)

Declares the output type for this spec.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type` | `Symbol` | :data for Hash output (json/yaml), :text for String output |

---

### .spec_name

`.spec_name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L43)

Sets or returns the spec name identifier.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `Symbol, nil` | the spec name to set |

**Returns**

`Symbol`, `nil` — the spec name, or nil if not set

---

## Instance Methods

### #generate

`#generate`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L219)

Generates the spec output.

Override this method in subclasses to produce the spec format.
Access API data via helper methods: [#types](#types), [#enums](#enums), [#raises](#raises),
[#error_codes](#error-codes), [#info](#info), [#each_resource](#each-resource), [#each_action](#each-action).

**Returns**

`Hash`, `String` — Hash for data specs, String for text specs

---
