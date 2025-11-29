# Single Table Inheritance

Apiwork supports Rails STI (Single Table Inheritance) with automatic type detection.

## Base Schema

Mark a schema as an STI base with `discriminator`:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminator

  attribute :name
  attribute :email
end
```

This uses Rails' `inheritance_column` (`:type` by default) as both the database column and JSON field name.

### Custom Field Name

To use a different name in JSON output:

```ruby
class ClientSchema < Apiwork::Schema::Base
  discriminator as: :kind  # JSON field is "kind", database column is still "type"

  attribute :name
  attribute :email
end
```

## Variant Schemas

Variant schemas inherit from the base and declare themselves with `variant`:

```ruby
class PersonClientSchema < ClientSchema
  variant

  attribute :birth_date
end

class CompanyClientSchema < ClientSchema
  variant

  attribute :industry
  attribute :registration_number
end
```

By default, the variant tag is the Rails `sti_name` (the class name, e.g., `"PersonClient"`).

### Custom Variant Tags

```ruby
class PersonClientSchema < ClientSchema
  variant as: :person  # Tag is "person" instead of "PersonClient"

  attribute :birth_date
end
```

## Defaults

When you omit options, Apiwork uses Rails conventions:

| Option | Default | Source |
|--------|---------|--------|
| Discriminator column | `:type` | `model_class.inheritance_column` |
| Discriminator JSON name | Same as column | `as:` option or column name |
| Variant tag | Class name | `model_class.sti_name` |

## Serialization

Objects are serialized based on their actual type:

```ruby
PersonClient.create!(name: "John", email: "john@example.com", birth_date: "1990-01-15")
# With discriminator as: :kind, variant as: :person
# => { "kind": "person", "name": "John", "email": "...", "birthDate": "1990-01-15" }

CompanyClient.create!(name: "Acme", email: "info@acme.com", industry: "Tech")
# With discriminator as: :kind, variant as: :company
# => { "kind": "company", "name": "Acme", "email": "...", "industry": "Tech" }
```

## Type Generation

STI generates a discriminated union type:

```typescript
type Client = PersonClient | CompanyClient;

interface PersonClient {
  kind: "person";
  name: string;
  email: string;
  birthDate: string;
}

interface CompanyClient {
  kind: "company";
  name: string;
  email: string;
  industry: string;
  registrationNumber: string;
}
```
