---
order: 22
prev: false
next: false
---

# Spec::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L23)

Base class for spec generators.

Subclass this to create custom spec formats (Protobuf, GraphQL, etc.).
Set `file_extension` and override `#generate` to produce output.

**Example: Custom spec generator**

```ruby
class ProtobufSpec < Apiwork::Spec::Base
  spec_name :protobuf
  file_extension '.proto'

  def generate
    # Build Protobuf schema from data (introspection hash)
  end
end

# Register the spec
Apiwork::Spec.register(ProtobufSpec)
```

## Class Methods

### .generate

`.generate(api_path, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L51)

Generates a spec for the given API path.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `api_path` | `String` | the API mount path |
| `options` | `Hash` | spec-specific options |

**Returns**

`String` — the generated spec

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

### .spec_name

`.spec_name(name = nil)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L32)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L106)

Generates the spec output.

Override this method in subclasses to produce the spec format.
Access API data via `data` (introspection hash).

**Returns**

`String` — the generated spec

---
