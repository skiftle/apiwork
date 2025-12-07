---
order: 99
---

# Examples

Complete working examples showing Apiwork features with full generated output.

Each example includes:
- API definition, models, schemas, contracts, and controllers
- Generated TypeScript types
- Generated Zod validators
- Generated OpenAPI spec
- Introspection output

## Available Examples

| Example | Description |
|---------|-------------|
| [Manual Contract](./manual-contract.md) | Defining contracts manually without schemas |
| [Schema-Driven Contract](./schema-driven-contract.md) | Using `schema!` to generate a complete contract from schema definitions |
| [Nested Saves](./nested-saves.md) | Create, update, and delete nested records in a single request |
| [Advanced Filtering](./advanced-filtering.md) | Complex queries with string patterns, numeric ranges, and logical operators |
| [Single Table Inheritance (STI)](./single-table-inheritance-sti.md) | Single Table Inheritance with automatic variant serialization and TypeScript union types |
| [Polymorphic Associations](./polymorphic-associations.md) | Comments that belong to different content types (posts, videos, images) |
| [Model Validation Errors](./model-validation-errors.md) | How Apiwork captures ActiveRecord validation errors and presents them in a unified format |
| [Custom Hash Responses](./custom-hash-responses.md) | Using respond_with with plain hashes instead of ActiveRecord models |
| [Encode, Decode & Empty](./encode-decode-empty.md) | Transform values on input/output and handle nil/empty string conversion |
| [Cursor Pagination](./cursor-pagination.md) | Navigate through large datasets using cursor-based pagination |
| [API Documentation](./api-documentation.md) | Document APIs with descriptions, examples, formats, and deprecation notices at every level |
| [API Documentation (I18n)](./api-documentation-i18n.md) | Using built-in I18n for translatable API documentation |
