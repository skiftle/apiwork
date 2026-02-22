---
order: 7
---
# Exports

Exports describe your API in formats understood by external tools. They are derived from [introspection](../introspection/) — the same structure that drives runtime validation.

## What Exports Do

- **Generate specifications** — OpenAPI, TypeScript, and Zod from one source
- **Stay in sync** — when your API changes, exports change with it
- **Extend** — build custom exports for any format

There is no separate schema to maintain. What runs in production is what gets exported.

## Declaration

Declare which exports to enable in your API definition:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
end
```

Once declared, exports can be generated via endpoints, rake tasks, or code.

## Next Steps

- [Generation](./generation.md) — endpoints, rake tasks, and programmatic generation
- [OpenAPI](./openapi.md) — OpenAPI specification export
- [TypeScript](./typescript.md) — TypeScript type definitions
- [Zod](./zod.md) — Zod schema export
- [Custom Exports](./custom-exports.md) — building your own export formats

#### See also

- [Export reference](../../reference/export/base) — programmatic generation API
