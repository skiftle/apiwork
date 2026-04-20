---
order: 2
---

# Apiwork JS

Apiwork JS is the JavaScript toolkit for Apiwork. It reads an Apiwork schema and generates TypeScript — pure types, Zod schemas, or a [Sorbus](./sorbus.md) contract.

Install:

```bash
pnpm add apiwork
# or
npm install apiwork
```

Full documentation: [apiwork-js](https://github.com/skiftle/apiwork-js).

## Codegen

Apiwork JS supports three targets — TypeScript, Zod, and Sorbus. Each reads the same `.apiwork` schema and emits different code. See an [example](/examples/representations#codegen) for the exact output.

### TypeScript

```bash
apiwork typescript http://localhost:3000/api/v1/.apiwork --outdir src/api/types
```

Emits pure TypeScript interfaces, types, and enums. Compile-time only, zero runtime cost.

Use when types alone are enough — documenting an API, feeding types into another tool, or generating editor hints without runtime validation.

### Zod

```bash
apiwork zod http://localhost:3000/api/v1/.apiwork --outdir src/api/schemas
```

Emits Zod schemas for every type in the API. Each schema validates at runtime and infers TypeScript types.

Use when you validate data at application boundaries — incoming requests, outgoing responses, or form inputs.

### Sorbus

```bash
apiwork sorbus http://localhost:3000/api/v1/.apiwork --outdir src/api/sorbus
```

Emits a typed [Sorbus](./sorbus.md) contract — endpoints, schemas, domain types, and a pre-materialized `Client` interface.

Use when you call the API from TypeScript. The generated contract feeds directly into `createClient` for typed filtering, sorting, pagination, nested writes, and error handling.

Output structure:

```
src/api/sorbus/
  api.ts           Shared types
  contract.ts      Sorbus contract
  client.ts        Client interface + createClient
  domains/         Domain type aliases
  endpoints/       OperationTree with materialized shapes
```

## Workflow

```
1. Change Rails (add column, change type, add enum value)
2. Regenerate the contract
3. TypeScript reports what broke
```

#### See also

- [apiwork-js](https://github.com/skiftle/apiwork-js) — source and full documentation
- [Sorbus](./sorbus.md) — the typed client that consumes the Sorbus contract
- [Apiwork schema](./exports/apiwork.md) — the input format
