---
order: 9
---

# Inheritance

Use `extends` to inherit all properties from another type. The child type includes all properties from the parent, plus any additional properties you define.

## Basic Inheritance

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

## Multiple Inheritance

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

## Generated Output

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

## Inheritance vs Merging

| Feature | Inheritance | Merging |
|---------|-------------|---------|
| Syntax | `extends :other` inside block | Multiple `object :name` declarations |
| Result | New type referencing parent | Single merged type |
| Use case | Create type hierarchies | Extend existing/generated types |

#### See also

- [Merging](./merging.md) — extending existing types
- [Contract::Base reference](../../../reference/contract-base.md) — type definition methods
