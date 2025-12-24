---
order: 19
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

### .generate(api_path, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L46)

Generates a spec for the given API path.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `api_path` | `String` | the API mount path |
| `options` | `Hash` | spec-specific options |

**Returns**

`String` — the generated spec

---

## Instance Methods

### #generate()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L114)

Generates the spec output.

Override this method in subclasses to produce the spec format.
Access API data via `data` (introspection hash).

**Returns**

`String` — the generated spec

---
