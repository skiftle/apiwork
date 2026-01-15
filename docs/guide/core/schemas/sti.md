---
order: 6
---

# Single Table Inheritance

Apiwork supports Rails Single Table Inheritance (STI) with automatic type inference. See [Inference](./inference.md) for all inference features.

## Base Schema

Mark a schema as an STI base with `discriminated!`:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminated!

  attribute :name
  attribute :email
end
```

By default, Apiwork uses Rails' `inheritance_column` (`:type`) as both the database column and JSON field name.

### Custom Field Name

To use a different name in JSON output:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminated! as: :kind  # JSON field is "kind", database column is still "type"

  attribute :name
  attribute :email
end
```

### Custom Database Column

To use a different database column:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminated! as: :kind, by: :category  # JSON field is "kind", database column is "category"

  attribute :name
  attribute :email
end
```

### What `discriminated!` Does

When you call `discriminated!`:

1. **Reads the inheritance column** from Rails (`model_class.inheritance_column`, typically `:type`)
2. **Sets the JSON field name** for the discriminator (`as:` argument or column name)
3. **Prepares the schema for variants** to register themselves

The base schema is not marked abstract until a variant registers. This happens automatically when a child schema calls `variant` — the parent becomes abstract (as if you called `abstract!`), preventing direct instantiation.

## Variant Schemas

Variant schemas inherit from the base and declare themselves with `variant`:

```ruby
class PersonClientSchema < ClientSchema
  variant as: :person

  attribute :birth_date
end

class CompanyClientSchema < ClientSchema
  variant as: :company

  attribute :industry
  attribute :registration_number
end
```

The `as:` argument is the variant tag used in JSON output. If omitted, it defaults to Rails' `sti_name` (the class name, e.g., `"PersonClient"`).

### What `variant` Does

When you call `variant`:

1. **Determines the tag** from the `as:` argument, or falls back to Rails' `sti_name`
2. **Stores the STI type** (`model_class.sti_name`) for runtime routing
3. **Registers with the parent schema**, adding itself to the parent's variant registry
4. **Marks the parent as abstract** (equivalent to calling `abstract!`), since it should no longer be used directly

This enables Apiwork to route serialization to the correct variant schema at runtime.

## Defaults

When you omit options, Apiwork uses Rails conventions:

| Option                  | Default        | Source                                  |
| ----------------------- | -------------- | --------------------------------------- |
| Discriminator column    | `:type`        | `by:` or `model_class.inheritance_column` |
| Discriminator JSON name | Same as column | `as:` or column name                    |
| Variant tag             | Class name     | `as:` or `model_class.sti_name`         |

## Serialization

Objects are serialized based on their actual type:

```ruby
PersonClient.create!(name: "John", email: "john@example.com", birth_date: "1990-01-15")
# With discriminated!, variant as: :person
# => { "type": "person", "name": "John", "email": "...", "birthDate": "1990-01-15" }

CompanyClient.create!(name: "Acme", email: "info@acme.com", industry: "Tech")
# With discriminated!, variant as: :company
# => { "type": "company", "name": "Acme", "email": "...", "industry": "Tech" }
```

## Type Generation

STI generates a discriminated union type.

### TypeScript

```typescript
export type Client = PersonClient | CompanyClient;

export interface PersonClient {
  type: "person";
  name: string;
  email: string;
  birthDate: string;
}

export interface CompanyClient {
  type: "company";
  name: string;
  email: string;
  industry: string;
  registrationNumber: string;
}
```

### Zod

```typescript
export const PersonClientSchema = z.object({
  type: z.literal("person"),
  name: z.string(),
  email: z.string(),
  birthDate: z.string(),
});

export const CompanyClientSchema = z.object({
  type: z.literal("company"),
  name: z.string(),
  email: z.string(),
  industry: z.string(),
  registrationNumber: z.string(),
});

export const ClientSchema = z.discriminatedUnion("type", [
  PersonClientSchema,
  CompanyClientSchema,
]);
```

#### See also

- [Schema::Base reference](../../../reference/schema-base.md) — `discriminated!` and `variant` methods

## Examples

See [Single Table Inheritance (STI)](/examples/single-table-inheritance-sti.md) for a complete working example with generated TypeScript, Zod, and OpenAPI output.
