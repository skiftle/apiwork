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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L92)

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

### #build_full_action_path

`#build_full_action_path(resource_data, action_data, parent_path = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L413)

Builds the full URL path for an action.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `resource_data` | `Hash` | resource data |
| `action_data` | `Hash` | action data |
| `parent_path` | `String, nil` | parent resource path |

**Returns**

`String` — full action path (e.g., "users/:user_id/posts/:id")

---

### #build_full_resource_path

`#build_full_resource_path(resource_data, parent_path = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L398)

Builds the full URL path for a resource.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `resource_data` | `Hash` | resource data |
| `parent_path` | `String, nil` | parent resource path |

**Returns**

`String` — full resource path (e.g., "users/:user_id/posts")

---

### #data

`#data`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L265)

Returns the data wrapper for introspection data.

This is the primary interface for accessing introspection data in spec generators.
Use this instead of accessing raw hash data directly.

**Returns**

[Spec::Data](spec-data)

**See also**

- [Spec::Data](spec-data)

---

### #each_action

`#each_action(resource_data, &block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L386)

Iterates over actions in a resource.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `resource_data` | `Hash` | resource data |

---

### #each_resource

`#each_resource(&block)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L367)

Iterates over all resources recursively (including nested).

---

### #enums

`#enums`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L335)

Returns all registered enums.

**Returns**

`Hash{Symbol => Hash}` — enum definitions with structure:
- :values [Array&lt;String&gt;] allowed values
- :description [String] enum description
- :example [String] example value
- :deprecated [Boolean] deprecation flag

---

### #error_codes

`#error_codes`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L353)

Returns detailed error code information.

**Returns**

`Hash{Symbol => Hash}` — error codes with structure:
- :status [Integer] HTTP status code
- :description [String] error description

---

### #generate

`#generate`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L208)

Generates the spec output.

Override this method in subclasses to produce the spec format.
Access API data via helper methods: [#types](#types), [#enums](#enums), [#raises](#raises),
[#error_codes](#error-codes), [#info](#info), [#each_resource](#each-resource), [#each_action](#each-action).

**Returns**

`Hash`, `String` — Hash for data specs, String for text specs

---

### #info

`#info`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L308)

Returns API metadata.

**Returns**

`Hash` — API info with structure:
- :title [String] API title
- :version [String] API version
- :description [String] API description
- :contact [Hash] contact info (:name, :email, :url)
- :license [Hash] license info (:name, :url)
- :servers [Array&lt;Hash&gt;] server URLs
- :summary [String] short summary
- :terms_of_service [String] ToS URL

---

### #raises

`#raises`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L343)

Returns API-level error codes that may be raised.

**Returns**

`Array<Symbol>` — error code keys (e.g., [:unauthorized, :not_found])

---

### #types

`#types`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L323)

Returns all registered custom types.

**Returns**

`Hash{Symbol => Hash}` — type definitions with structure:
- :type [Symbol] :object or :union
- :shape [Hash] param definitions (for objects)
- :variants [Array&lt;Hash&gt;] union variants
- :discriminator [Symbol] union discriminator field
- :description [String] type description
- :example [Object] example value
- :deprecated [Boolean] deprecation flag

---
