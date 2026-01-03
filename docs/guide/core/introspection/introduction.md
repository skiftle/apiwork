---
order: 1
---

# Introduction

Introspection allows an API to describe itself through a rich object model.

Resources, actions, types, enums, and error codes are exposed as explicit objects that mirror the API’s structure and behavior.

This serves two purposes:

- **Development** - inspect what your contracts expose, including dynamically generated types
- **Generation** - [spec generators](../specs/introduction.md) and documentation read introspection data directly

The data is exposed through facade objects with predicates for type-checking and accessors for navigation.

---

## Facade Objects

Introspection returns typed objects, not raw hashes:

```ruby
api = Apiwork::API.introspect('/api/v1')

api.resources[:invoices].actions[:show].response.body
# => Param::Array
```

Predicates enable type-checking:

```ruby
status = api.types[:invoice].shape[:status]
status.enum?     # => true
status.enum      # => ["draft", "sent", "due", "paid"]
status.optional? # => false
```

Accessors provide navigation:

```ruby
# Array element type
array_param.of  # => Param for element type

# Object fields
object_param.shape  # => Hash{Symbol => Param}

# Union variants
union_param.variants  # => Array<Param>
```

---

## Hierarchy

```
API
├── info
│   ├── title, version, description
│   ├── contact
│   ├── license
│   └── servers
├── resources
│   ├── identifier, path
│   ├── actions
│   │   ├── method, path, raises
│   │   ├── request
│   │   │   ├── query
│   │   │   └── body
│   │   └── response
│   │       └── body
│   └── resources (nested)
├── types
│   ├── shape (object types)
│   └── variants (union types)
├── enums
└── error_codes
```

---

## During Development

When building contracts, introspection helps you see exactly what gets exposed. The adapter generates types dynamically based on your schema - filters, pagination, sorting - that don't exist as explicit code.

Call `.to_h` on any object for a hash representation:

```ruby
api.to_h
# => { path: "/api/v1", resources: {...}, types: {...} }

action.request.to_h
# => { query: {...}, body: {...} }
```

This is useful for debugging or understanding what a contract exposes.

---

## Usage

- [API Introspection](./api-introspection.md) - entry point for full API
- [Contract Introspection](./contract-introspection.md) - entry point for single contract

See the [reference documentation](../../reference/introspection-api.md) for complete method details.
