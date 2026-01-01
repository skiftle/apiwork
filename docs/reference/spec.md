---
order: 21
prev: false
next: false
---

# Spec

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L5)

## Class Methods

### .generate

`.generate(spec_name, api_path, **options)`

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L43)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L15)

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

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L52)

Clears all registered specs. Intended for test cleanup.

**Example**

```ruby
Apiwork::Spec.reset!
```

---
