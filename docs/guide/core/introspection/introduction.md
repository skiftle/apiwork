---
order: 1
---

# Introduction

Introspection describes an API through an object model.

Resources, actions, types, enums, and error codes are exposed as explicit objects that reflect the API’s structure and behavior.

This serves two purposes:

- **Development** – inspect what is exposed, including dynamically generated types
- **Generation** – [spec generators](../specs/introduction.md) and documentation read introspection directly

Introspection exposes an object facade. Each object represents a part of the API and provides type predicates and navigation accessors.

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

When building contracts, introspection provides visibility into what is exposed. Adapters may derive types from schemas at runtime, and features such as filtering, pagination, and sorting may not exist as explicit code. Introspection makes these derived structures visible at the API and contract level.

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

See the [reference documentation](../../../reference/introspection-api.md) for complete method details.
