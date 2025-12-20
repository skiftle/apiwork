---
order: 45
prev: false
next: false
---

# Spec

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L5)

## Class Methods

### .generate(identifier, api_path, **options)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L41)

Generates a spec for an API.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `identifier` | `Symbol` | the spec identifier (:openapi, :typescript, :zod) |
| `api_path` | `String` | the API mount path |
| `options` | `Hash` | spec-specific options |

**Returns**

`String` — the generated spec

**Example**

```ruby
Apiwork::Spec.generate(:openapi, '/api/v1')
Apiwork::Spec.generate(:typescript, '/api/v1', namespace: 'Api')
```

---

### .register(klass)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L14)

Registers a spec generator.

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `klass` | `Class` | the spec class (subclass of Spec::Base with register_as) |

**Example**

```ruby
Apiwork::Spec.register(GraphqlSpec)
```

---

### .registered?(identifier)

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L26)

**Returns**

`Boolean` — 

---

### .reset!()

[GitHub](https://github.com/skiftle/apiwork/blob/main/lib/apiwork/spec.rb#L50)

Clears all registered specs. Intended for test cleanup.

**Example**

```ruby
Apiwork::Spec.reset!
```

---
