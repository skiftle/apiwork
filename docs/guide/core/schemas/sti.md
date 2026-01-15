---
order: 6
---

# Single Table Inheritance

Apiwork supports Rails Single Table Inheritance (STI) with automatic type inference. See [Inference](./inference.md) for all inference features.

## Base Schema

Mark a schema as an STI base with `discriminated!`:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminated! :kind

  attribute :name
  attribute :email
end
```

The argument is the JSON field name for the discriminator. Apiwork reads the database column from Rails' `inheritance_column` (`:type` by default).

### Custom Database Column

To use a different database column:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminated! :kind, column: :category  # JSON field is "kind", database column is "category"

  attribute :name
  attribute :email
end
```

### What `discriminated!` Does

When you call `discriminated!`:

1. **Reads the inheritance column** from Rails (`model_class.inheritance_column`, typically `:type`)
2. **Sets the JSON field name** for the discriminator (your positional argument)
3. **Prepares the schema for variants** to register themselves

The base schema is not marked abstract until a variant registers. This happens automatically when a child schema calls `variant` — the parent becomes abstract (as if you called `abstract!`), preventing direct instantiation.

## Variant Schemas

Variant schemas inherit from the base and declare themselves with `variant`:

```ruby
class PersonClientSchema < ClientSchema
  variant :person

  attribute :birth_date
end

class CompanyClientSchema < ClientSchema
  variant :company

  attribute :industry
  attribute :registration_number
end
```

The argument is the variant tag used in JSON output. If omitted, it defaults to Rails' `sti_name` (the class name, e.g., `"PersonClient"`).

### What `variant` Does

When you call `variant`:

1. **Determines the tag** from your positional argument, or falls back to Rails' `sti_name`
2. **Stores the STI type** (`model_class.sti_name`) for runtime routing
3. **Registers with the parent schema**, adding itself to the parent's variant registry
4. **Marks the parent as abstract** (equivalent to calling `abstract!`), since it should no longer be used directly

This enables Apiwork to route serialization to the correct variant schema at runtime.

## Defaults

When you omit options, Apiwork uses Rails conventions:

| Option                  | Default        | Source                                      |
| ----------------------- | -------------- | ------------------------------------------- |
| Discriminator column    | `:type`        | `model_class.inheritance_column`            |
| Discriminator JSON name | Required       | Positional argument to `discriminated!`     |
| Variant tag             | Class name     | Positional argument or `model_class.sti_name` |

## Serialization

Objects are serialized based on their actual type:

```ruby
PersonClient.create!(name: "John", email: "john@example.com", birth_date: "1990-01-15")
# With discriminated! :kind, variant :person
# => { "kind": "person", "name": "John", "email": "...", "birthDate": "1990-01-15" }

CompanyClient.create!(name: "Acme", email: "info@acme.com", industry: "Tech")
# With discriminated! :kind, variant :company
# => { "kind": "company", "name": "Acme", "email": "...", "industry": "Tech" }
```

## Type Generation

STI generates a discriminated union type.

### TypeScript

```typescript
export type Client = PersonClient | CompanyClient;

export interface PersonClient {
  kind: "person";
  name: string;
  email: string;
  birthDate: string;
}

export interface CompanyClient {
  kind: "company";
  name: string;
  email: string;
  industry: string;
  registrationNumber: string;
}
```

### Zod

```typescript
export const PersonClientSchema = z.object({
  kind: z.literal("person"),
  name: z.string(),
  email: z.string(),
  birthDate: z.string(),
});

export const CompanyClientSchema = z.object({
  kind: z.literal("company"),
  name: z.string(),
  email: z.string(),
  industry: z.string(),
  registrationNumber: z.string(),
});

export const ClientSchema = z.discriminatedUnion("kind", [
  PersonClientSchema,
  CompanyClientSchema,
]);
```

#### See also

- [Schema::Base reference](../../../reference/schema-base.md) — `discriminated!` and `variant` methods

## Examples

See [Single Table Inheritance (STI)](/examples/single-table-inheritance-sti.md) for a complete working example with generated TypeScript, Zod, and OpenAPI output.
