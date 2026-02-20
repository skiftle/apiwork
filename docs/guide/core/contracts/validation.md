---
order: 5
---

# Validation

Contracts validate requests before your controller runs. If validation fails, the controller is never invoked.

## Request Lifecycle

Every request goes through these steps:

1. **Coerce** — query parameters arrive as strings and are converted to declared types
2. **Validate** — check types, required fields, constraints, and reject unknown fields
3. **Deserialize** — map validated data through the representation
4. **Transform** — apply field name mappings

If validation fails at step 2, Apiwork returns a `400 Bad Request` with structured errors. Steps 3 and 4 only run on valid data.

## Query vs Body

Query parameters and body parameters are validated separately, but follow different coercion rules:

| Source | Format | Coercion |
|--------|--------|----------|
| Query (`?key=value`) | URL-encoded strings | Automatic — strings are coerced to declared types |
| Body (JSON) | Already typed | None — values are validated as-is |

Query parameters need coercion because URL query strings are always text. A `boolean? :active` in your query definition accepts `"true"`, `"1"`, or `"yes"` from the URL and coerces it to `true`.

## Accessing Validated Data

After validation succeeds, access the validated data in your controller:

```ruby
def create
  contract.body[:invoice]
  # => { number: "INV-001", status: "draft", customer_id: 42 }
end

def index
  contract.query[:filter]
  # => { status: { eq: "sent" } }
end
```

Values are coerced, validated, and transformed. What your controller receives matches the types you declared.

## Validation Rules

The validator checks each field in order:

| Check | Error code | When |
|-------|-----------|------|
| Required field present | `field_missing` | Non-optional field is absent or null |
| Null not allowed | `value_null` | Value is null on a non-nullable field |
| Enum membership | `value_invalid` | Value not in allowed set |
| Type match | `type_invalid` | Value does not match declared type |
| String length | `string_too_short`, `string_too_long` | Outside min/max length |
| Numeric range | `number_too_small`, `number_too_large` | Outside min/max value |
| Array size | `array_too_small`, `array_too_large` | Outside min/max items |
| Unknown field | `field_unknown` | Field not declared in the contract |
| Nesting depth | `depth_exceeded` | Exceeds maximum nesting (default 10) |

All issues are collected in a single pass. A response may contain multiple errors.

## Error Response

When validation fails, the response identifies the layer and lists all issues:

```json
{
  "layer": "contract",
  "issues": [
    {
      "code": "field_missing",
      "detail": "Required",
      "path": ["invoice", "number"],
      "pointer": "/invoice/number",
      "meta": { "field": "number" }
    },
    {
      "code": "type_invalid",
      "detail": "Invalid type",
      "path": ["invoice", "sent"],
      "pointer": "/invoice/sent",
      "meta": { "field": "sent", "expected": "boolean" }
    }
  ]
}
```

See [Contract Errors](../errors/contract-errors.md) for the full error format.

## Response Checking

After your controller runs, Apiwork checks the response against the contract:

- **Development** — mismatches are logged to the Rails logger
- **Production** — no checks, no overhead

Response checking never returns errors to clients. It exists to catch shape mismatches during development before they reach production.

## Strict In, Lenient Out

Request validation is strict. Invalid data returns `400 Bad Request`. Unknown fields are rejected. Missing required fields fail. Type mismatches fail.

Response checking is lenient. Mismatches are logged but never break your API. Extra fields are allowed. The response is always sent.

This asymmetry is intentional. Clients depend on the request contract — breaking it protects them from sending bad data. The response contract is a development aid, not an enforcement mechanism.

#### See also

- [Errors](../errors/introduction.md) — the unified error model
- [Contract Errors](../errors/contract-errors.md) — all contract error codes
- [Contract::Base reference](../../../reference/contract/base.md) — all contract methods and options
