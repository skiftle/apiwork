---
order: 5
---
# Introspection

Introspection exposes API structure as Ruby objects — resources, actions, types, and params that you can query programmatically.

Resources, actions, types, enums, and error codes are exposed as explicit objects that reflect the API's structure and behavior.

This serves two purposes:

- **Development** – inspect what is exposed, including dynamically generated types
- **Generation** – [exports](../exports/) and documentation read introspection directly

Each introspection object provides type predicates and navigation accessors.

---

## Facade Objects

Introspection returns typed objects:

```ruby
api = Apiwork::API.introspect('/api/v1')

action = api.resources[:invoices].actions[:show]
body = action.response.body
body.shape.keys  # => [:invoice, :meta]
```

Predicates for type-checking:

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
├── enums
├── error_codes
└── raises
```

---

## During Development

Adapters derive types from representations at runtime. Introspection makes these generated structures visible.

Call `.to_h` on any introspection object to get a hash representation:

```ruby
api.to_h
# => { path: "/api/v1", resources: {...}, types: {...} }

action.request.to_h
# => { query: {...}, body: {...} }
```

---

## Usage

- [API Introspection](./api-introspection.md) - entry point for full API
- [Contract Introspection](./contract-introspection.md) - entry point for single contract

See the [reference documentation](../../../reference/introspection/api/) for complete method details.
