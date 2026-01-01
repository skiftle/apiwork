---
order: 22
prev: false
next: false
---

# Spec

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L9)

Registry for spec generators.

Built-in specs: :openapi, :typescript, :zod, :introspection.
Use [.generate](#generate) to produce specs for an API.

## Class Methods

### .generate

`.generate(spec_name, api_path, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L47)

Generates a spec for an API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `spec_name` | `Symbol` | the spec name (:openapi, :typescript, :zod) |
| `api_path` | `String` | the API mount path |
| `options` | `Hash` | spec-specific options |

**Returns**

`String` — the generated spec

**See also**

- [Spec::Base](spec-base)

**Example**

```ruby
Apiwork::Spec.generate(:openapi, '/api/v1')
Apiwork::Spec.generate(:typescript, '/api/v1', locale: :sv, key_format: :camel)
```

---

### .register

`.register(klass)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L19)

Registers a spec generator.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | a [Spec::Base](spec-base) subclass with spec_name set |

**See also**

- [Spec::Base](spec-base)

**Example**

```ruby
Apiwork::Spec.register(JSONSchemaSpec)
```

---

### .reset!

`.reset!`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L56)

Clears all registered specs. Intended for test cleanup.

**Example**

```ruby
Apiwork::Spec.reset!
```

---
