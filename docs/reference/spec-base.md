---
order: 44
prev: false
next: false
---

# Spec::Base

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L23)

Base class for spec generators.

Subclass this to create custom spec formats (Protobuf, GraphQL, etc.).
Override `#generate` to produce output and `.file_extension` for the file type.

**Example: Custom spec generator**

```ruby
class ProtobufSpec < Apiwork::Spec::Base
  register_as :protobuf

  def self.file_extension
    'proto'
  end

  def generate
    # Build Protobuf schema from @data (introspection hash)
  end
end
```

## Class Methods

### .file_extension()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L49)

---

### .generate(api_path, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L40)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L81)

Generates the spec output.

Override this method in subclasses to produce the spec format.
Access API data via `@data` (introspection hash).

**Returns**

`String` — the generated spec

---

### #initialize(api_path, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec/base.rb#L54)

**Returns**

`Base` — a new instance of Base

---
