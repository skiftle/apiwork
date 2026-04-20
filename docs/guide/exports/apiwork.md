---
order: 4
---

# Apiwork

The Apiwork export generates an Apiwork schema — a portable JSON description of the API. The schema mirrors Apiwork's internal model exactly, with no translation losses between runtime and output.

The schema is the input for [Apiwork JS](../apiwork-js.md), which generates TypeScript types, Zod schemas, or a [Sorbus](../sorbus.md) contract. Anything else that reads JSON can consume it directly.

## Configuration

```ruby
Apiwork::API.define '/api/v1' do
  export :apiwork
end
```

The export is reachable at `/.apiwork` by default.

## Options

```ruby
export :apiwork do
  path '/.apiwork'        # Custom endpoint path (default: /.apiwork)
  key_format :camel       # Transform keys to camelCase
end
```

| Option | Values | Default |
| --- | --- | --- |
| `format` | `json`, `yaml` | `json` |

## Output

```json
{
  "base_path": "/api/v1",
  "fingerprint": "abc123def456...",
  "info": { ... },
  "locales": ["en", "sv"],
  "enums": [ ... ],
  "error_codes": [ ... ],
  "types": [ ... ],
  "resources": [ ... ]
}
```

| Field | Description |
| --- | --- |
| `base_path` | API mount path |
| `fingerprint` | 16-character identifier derived from the Rails application name and `base_path`; stable across API changes |
| `info` | API metadata (title, version, contact, etc.) |
| `locales` | Locales the API supports |
| `enums` | Named enum definitions |
| `error_codes` | Error codes the API may emit |
| `types` | Named type definitions in topological order, with recursive types flagged |
| `resources` | Resources with nested actions |

Each type, action, and param carries the same structural information as the runtime contract — there is no schema loss between runtime and the generated file.

#### See also

- [Generation](./generation.md) — endpoints, rake tasks, programmatic generation
- [Custom Exports](./custom-exports.md) — building custom export formats
- [Export reference](../../reference/export/base) — programmatic generation API
