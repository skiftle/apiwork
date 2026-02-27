---
order: 8
---
# Exports

Exports describe the API in formats that external tools understand. They come from [introspection](../introspection/) — the same structure that drives runtime validation.

## What Exports Do

- **Generate specifications** — OpenAPI, TypeScript, Zod, and Sorbus from one source
- **Stay in sync** — when the API changes, exports change with it
- **Extend** — build custom exports for any format

There is no separate schema to maintain. What runs in production is what gets exported.

## Declaration

Declare which exports to enable in the API definition:

```ruby
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
  export :sorbus
end
```

Once declared, exports can be generated via endpoints, rake tasks, or code.

## Next Steps

- [Generation](./generation.md) — endpoints, rake tasks, and programmatic generation
- [OpenAPI](./openapi.md) — OpenAPI specification
- [TypeScript](./typescript.md) — TypeScript type definitions
- [Zod](./zod.md) — Zod schemas
- [Sorbus](./sorbus.md) — Sorbus contract
- [Custom Exports](./custom-exports.md) — building custom export formats

#### See also

- [Export reference](../../reference/export/base) — programmatic generation API
