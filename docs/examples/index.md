---
order: 99
---

# Examples

Complete working examples showing Apiwork features with full generated output.

Each example includes:
- API definition, models, representations, contracts, and controllers
- Generated TypeScript types
- Generated Zod validators
- Generated OpenAPI export
- Introspection output

## Available Examples

| Example | Description |
|---------|-------------|
| [Representations](./representations.md) | Generate a complete contract from representation definitions |
| [Manual Contracts](./manual-contracts.md) | Define contracts manually without representations |
| [Filtering and Sorting](./filtering-and-sorting.md) | Complex queries with string patterns, numeric ranges, and logical operators |
| [Offset Pagination](./offset-pagination.md) | Offset-based pagination with page number and page size query parameters |
| [Cursor Pagination](./cursor-pagination.md) | Cursor-based pagination for navigating large datasets |
| [Includes](./includes.md) | Load associations on demand with include query parameters |
| [Nested Saves](./nested-saves.md) | Create, update, and delete nested records in a single request |
| [Write Modes](./write-modes.md) | Control which fields are accepted on create vs update |
| [Single Table Inheritance](./single-table-inheritance.md) | Single Table Inheritance with automatic variant serialization and TypeScript union types |
| [Polymorphic Associations](./polymorphic-associations.md) | Comments that belong to different content types (posts, videos) |
| [Union Types](./union-types.md) | Discriminated unions for polymorphic request and response shapes |
| [Inline Types](./inline-types.md) | Define typed JSON columns with object shapes, arrays, and nested structures |
| [Type Imports](./type-imports.md) | Share type definitions between contracts with import |
| [Value Transforms](./value-transforms.md) | Transform values on input/output and handle nil/empty string conversion |
| [Key and Path Formats](./key-and-path-formats.md) | PascalCase keys with `key_format :pascal` and kebab-case paths with `path_format :kebab` |
| [Validation Errors](./validation-errors.md) | ActiveRecord validation errors captured and presented in a unified format |
| [Documentation](./documentation.md) | Document APIs with descriptions, examples, formats, and deprecation notices at every level |
| [Documentation I18n](./documentation-i18n.md) | Translatable API documentation with built-in I18n support |
| [Hash Responses](./hash-responses.md) | Expose plain hashes instead of ActiveRecord models |
