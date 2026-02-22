---
order: 9
---

# Type Reuse

Apiwork provides two ways to reuse types: inheritance with `extends` and composition with `merge`. For reusable field groups that should not appear in exports, use `fragment`.

## Inheritance with extends

Use `extends` to create a type hierarchy. The relationship is preserved in the output.

### Basic Inheritance

```ruby
object :person do
  string :name
  string :email
end

object :employee do
  extends :person
  string :employee_id
  string :department
end
```

The `:employee` object has four properties: `name`, `email`, `employee_id`, and `department`.

### Multiple Inheritance

Call `extends` multiple times to inherit from multiple types:

```ruby
object :contactable do
  string :email
  string :phone
end

object :timestamped do
  datetime :created_at
  datetime :updated_at
end

object :customer do
  extends :contactable
  extends :timestamped
  string :name
end
```

### Generated Output

**TypeScript:**
```typescript
export interface Employee extends Person {
  employeeId: string;
  department: string;
}

// Or without own properties:
export type Admin = User;

// Multiple inheritance:
export type Customer = Contactable & Timestamped & { name: string };
```

**Zod:**
```typescript
export const EmployeeSchema = PersonSchema.extend({
  employeeId: z.string(),
  department: z.string()
});

// Or without own properties:
export const AdminSchema = UserSchema;

// Multiple inheritance:
export const CustomerSchema = ContactableSchema.merge(TimestampedSchema).extend({
  name: z.string()
});
```

**OpenAPI:**
```yaml
Employee:
  allOf:
    - $ref: '#/components/schemas/Person'
    - type: object
      properties:
        employeeId:
          type: string
        department:
          type: string
```

## Composition with merge

Use `merge` to include properties from another type without creating an inheritance relationship. The properties are inlined - no reference appears in the output.

### Basic Usage

```ruby
object :auditable do
  datetime :created_at
  datetime :updated_at
end

object :invoice do
  merge :auditable
  string :number
end
```

The `:invoice` object has three properties: `created_at`, `updated_at`, and `number`. Unlike `extends`, the output contains no reference to `:auditable`.

### Multiple Merges

```ruby
object :entity do
  merge :identifiable
  merge :timestamped
  merge :auditable
  string :name
end
```

### Own Properties Override Merged

```ruby
object :base do
  string :name
end

object :child do
  merge :base
  string :name, description: "Overridden description"
end
```

## extends vs merge

| Feature | extends | merge |
|---------|---------|--------|
| Includes properties | Yes | Yes |
| Reference in output | Yes (allOf/extends) | No (inlined) |
| Use case | Type hierarchies | Mixins, composition |

**Use `extends` when:**
- You want a visible inheritance relationship
- Types share an "is-a" relationship

**Use `merge` when:**
- You want to reuse properties without inheritance
- Types share a "has-properties-of" relationship
- You're composing from multiple sources

## Fragments

Fragments are types that only exist for merging. They do not appear as standalone types in introspection or exports.

```ruby
fragment :timestamps do
  datetime :created_at
  datetime :updated_at
end

object :invoice do
  merge :timestamps
  string :number
  decimal :total
end

object :customer do
  merge :timestamps
  string :name
  string :email
end
```

Both `:invoice` and `:customer` include `created_at` and `updated_at` fields. The `:timestamps` fragment itself does not appear in introspection, OpenAPI, TypeScript, or Zod output.

### Contract-scoped Fragments

Fragments defined in a contract follow the same scoping rules as objects:

```ruby
class InvoiceContract < Contract::Base
  fragment :auditable do
    string :created_by
    string :updated_by
  end

  object :invoice do
    merge :auditable
    string :number
  end
end
```

Contract-scoped fragments are importable via `import`, just like objects.

### When to Use Fragments

| Concept | Use |
|---------|-----|
| `object` | Standalone type visible in exports |
| `fragment` | Reusable field group, invisible in exports |
| `extends` | Inheritance with visible relationship |
| `merge` | Composition (works with both objects and fragments) |

Use fragments when you need reusable field groups but do not want them in your generated API specs.

## Declaration Order

Define types in any order. Apiwork automatically resolves dependencies and outputs types in the correct order.

```ruby
# This works - child defined before parent
object :employee do
  extends :person
  string :employee_id
end

object :person do
  string :name
end
```

#### See also

- [Declaration Merging](./declaration-merging.md) — extending existing types with multiple declarations
- [Contract::Base reference](../../../reference/apiwork/contract/base.md) — type definition methods
