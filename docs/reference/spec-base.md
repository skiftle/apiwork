---
order: 37
prev: false
next: false
---

# Spec::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L34)

Base class for spec generators.

Subclass this to create custom spec formats. Declare output type
and override `#generate` to produce output.

**Example: Hash spec (supports json/yaml)**

```ruby
class OpenAPISpec < Apiwork::Spec::Base
  spec_name :openapi
  output :hash

  def generate
    { openapi: '3.1.0', ... }  # Returns Hash
  end
end
```

**Example: String spec (fixed format)**

```ruby
class ProtobufSpec < Apiwork::Spec::Base
  spec_name :protobuf
  output :string
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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L85)

Sets the file extension for string specs.

Only valid for specs with `output :string`. Hash specs derive
their extension from the format (:json → .json, :yaml → .yaml).

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `file_extension` | `String, nil` | the file extension (e.g., '.ts') |

**Returns**

`String`, `nil` — the file extension

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
| `type` | `Symbol` | :hash for Hash output (json/yaml), :string for String output |

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

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L263)

Returns the API introspection facade.

This is the primary interface for accessing introspection data in spec generators.

**Returns**

[Introspection::API](introspection-api)

**See also**

- [Introspection::API](introspection-api)

---

### #generate

`#generate`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L207)

Generates the spec output.

Override this method in subclasses to produce the spec format.
Access API data via the [#data](#data) method which provides typed access
to types, enums, resources, actions, and other introspection data.

**Returns**

`Hash`, `String` — Hash for hash specs, String for string specs

**See also**

- [Introspection::API](introspection-api)

---
