# Discriminated Unions

A discriminated union (also called a tagged union) is a data structure that can be one of several variants, where a single field - the discriminator - tells you which variant you're dealing with.

Think of it like a switch statement, but for your data.

## Why discriminated unions?

Regular unions are ambiguous. Say you have:

```ruby
param :filter, type: :union do
  variant type: :string_filter
  variant type: :integer_filter
end
```

When you receive data, which variant is it? You have to try parsing both and see what works. That's slow and error-prone.

Discriminated unions solve this:

```ruby
param :filter, type: :union, discriminator: :type do
  variant tag: 'string', type: :string_filter
  variant tag: 'integer', type: :integer_filter
end
```

Now you know immediately: if `type: "string"`, it's a string filter. If `type: "integer"`, it's an integer filter. One field determines everything.

## Basic syntax

Three things make a discriminated union:

1. **discriminator** - the field name that determines the variant
2. **tag** - the exact value of the discriminator for each variant
3. **variants** - the possible shapes

```ruby
param :payment, type: :union, discriminator: :method do
  variant tag: 'card' do
    param :method, type: :literal, value: 'card'
    param :card_number, type: :string
    param :cvv, type: :string
  end

  variant tag: 'bank' do
    param :method, type: :literal, value: 'bank'
    param :account_number, type: :string
    param :routing_number, type: :string
  end
end
```

When `method: "card"`, you get card fields. When `method: "bank"`, you get bank fields.

## The discriminator field

The discriminator must be a [literal type](literal-types.md) in each variant. This ensures type safety:

```ruby
variant tag: 'card' do
  # The discriminator field MUST be a literal matching the tag
  param :method, type: :literal, value: 'card'
  # ... other fields
end
```

The tag and the literal value should match. Apiwork uses the tag to route validation to the right variant.

## Using custom types in variants

Variants can reference custom types:

```ruby
# Define custom types for each payment method
type :card_payment do
  param :card_number, type: :string
  param :cvv, type: :string
  param :expiry, type: :string
end

type :bank_payment do
  param :account_number, type: :string
  param :routing_number, type: :string
end

# Use them in a discriminated union
action :process_payment do
  input do
    param :payment, type: :union, discriminator: :method do
      variant tag: 'card', type: :card_payment
      variant tag: 'bank', type: :bank_payment
    end
  end
end
```

This is cleaner than inline definitions when variants are complex.

## Variants with inline shapes

For simpler cases, define the shape inline:

```ruby
param :search, type: :union, discriminator: :kind do
  variant tag: 'text' do
    param :kind, type: :literal, value: 'text'
    param :query, type: :string
    param :case_sensitive, type: :boolean, default: false
  end

  variant tag: 'range' do
    param :kind, type: :literal, value: 'range'
    param :min, type: :integer
    param :max, type: :integer
  end
end
```

## Array variants

Variants can be arrays:

```ruby
param :items, type: :union, discriminator: :item_type do
  variant tag: 'products', type: :array, of: :product_schema
  variant tag: 'services', type: :array, of: :service_schema
end
```

When `item_type: "products"`, you get an array of products. When `item_type: "services"`, an array of services.

## Real-world example: Filter unions

One powerful pattern is filterable attributes with different filter types:

```ruby
action :index do
  input do
    param :filters, type: :object do
      # Title filter - string operations
      param :title, type: :union, discriminator: :operator do
        variant tag: 'equals' do
          param :operator, type: :literal, value: 'equals'
          param :value, type: :string
        end

        variant tag: 'contains' do
          param :operator, type: :literal, value: 'contains'
          param :value, type: :string
        end
      end

      # Created date filter - range operations
      param :created_at, type: :union, discriminator: :operator do
        variant tag: 'before' do
          param :operator, type: :literal, value: 'before'
          param :date, type: :string
        end

        variant tag: 'between' do
          param :operator, type: :literal, value: 'between'
          param :start_date, type: :string
          param :end_date, type: :string
        end
      end
    end
  end
end
```

Each filter type gets exactly the parameters it needs, no more, no less.

## Auto-generated discriminated unions

When you use schema-based resource contracts, Apiwork automatically generates discriminated union responses for you:

```ruby
class PostContract < Apiwork::Contract::Base
  schema PostSchema

  # This automatically gets an output that's a discriminated union!
  action :create do
    input do
      param :title, type: :string
      param :body, type: :string
    end
  end
end
```

The output looks like this:

```ruby
output do
  # Discriminated union based on 'ok' field
  param :ok, type: :boolean, required: true

  # Success variant (ok: true)
  param :post, type: :post_schema, required: false
  param :meta, type: :object, required: false

  # Error variant (ok: false)
  param :errors, type: :array, of: :error, required: false
end
```

In serialized form, this becomes a proper discriminated union:

```json
{
  "type": "union",
  "discriminator": "ok",
  "variants": [
    {
      "tag": "true",
      "type": "object",
      "shape": {
        "ok": { "type": "literal", "value": true, "required": true },
        "post": { "type": "post_schema", "required": false },
        "meta": { "type": "object", "required": false }
      }
    },
    {
      "tag": "false",
      "type": "object",
      "shape": {
        "ok": { "type": "literal", "value": false, "required": true },
        "errors": { "type": "array", "of": "error", "required": false }
      }
    }
  ]
}
```

This means code generators can create type-safe clients:

```typescript
type CreatePostResponse =
  | { ok: true; post: Post; meta?: object }
  | { ok: false; errors?: Error[] }

// TypeScript knows: if ok is true, you have a post. If false, you have errors.
if (response.ok) {
  console.log(response.post.title); // ✅ TypeScript knows 'post' exists
} else {
  console.log(response.errors); // ✅ TypeScript knows 'errors' exists
}
```

## Boolean discriminators

You can use booleans as discriminators:

```ruby
param :result, type: :union, discriminator: :ok do
  variant tag: 'true' do
    param :ok, type: :literal, value: true
    param :data, type: :object
  end

  variant tag: 'false' do
    param :ok, type: :literal, value: false
    param :error, type: :string
  end
end
```

Note that tags are strings (`'true'` and `'false'`), even though the discriminator value is a boolean. Apiwork normalizes boolean values to strings for tag matching.

## When to use discriminated unions

**Use discriminated unions when:**
- Different cases need different fields
- You want type-safe branching in clients
- You're modeling "this OR that" where the shape differs
- You need efficient parsing (check one field, route to the right validator)

**Use regular unions when:**
- Variants are primitive types (string | integer)
- You don't control the discriminator field
- The data format is already established without a discriminator

**Don't use unions when:**
- All cases have the same shape (just use an object)
- You want multiple values of the same type (use an array)

## Discriminated unions vs enums

Enums are about restricting *values*. Discriminated unions are about restricting *shapes*.

```ruby
# Enum: status can be 'draft', 'published', or 'archived'
param :status, type: :string, enum: ['draft', 'published', 'archived']

# Discriminated union: different shapes based on status
param :content, type: :union, discriminator: :status do
  variant tag: 'draft' do
    param :status, type: :literal, value: 'draft'
    param :draft_body, type: :string
    param :last_edited, type: :string
  end

  variant tag: 'published' do
    param :status, type: :literal, value: 'published'
    param :published_body, type: :string
    param :published_at, type: :string
  end
end
```

If the fields are the same across cases, use an enum. If the fields differ, use a discriminated union.

## Validation

When validating a discriminated union, Apiwork:

1. Checks the discriminator field exists
2. Reads its value to determine which variant
3. Validates the entire structure against that variant's shape
4. Fails if the discriminator value doesn't match any tag

This is much faster than trying each variant until one works.

## Schema generation: Type safety across the stack

Discriminated unions aren't just for runtime validation - they generate schemas that give you compile-time safety in TypeScript, Zod, and other languages.

### From contract to schemas

Let's use a realistic example - a payment method union:

```ruby
action :process_payment do
  input do
    param :payment, type: :union, discriminator: :method do
      variant tag: 'card' do
        param :method, type: :literal, value: 'card'
        param :card_number, type: :string
        param :cvv, type: :string
        param :expiry, type: :string
      end

      variant tag: 'bank' do
        param :method, type: :literal, value: 'bank'
        param :account_number, type: :string
        param :routing_number, type: :string
      end

      variant tag: 'paypal' do
        param :method, type: :literal, value: 'paypal'
        param :email, type: :string
      end
    end
  end
end
```

### OpenAPI 3.1

Apiwork generates OpenAPI with `oneOf` and discriminator:

```json
{
  "type": "object",
  "properties": {
    "payment": {
      "discriminator": {
        "propertyName": "method"
      },
      "oneOf": [
        {
          "type": "object",
          "properties": {
            "method": { "type": "string", "enum": ["card"] },
            "card_number": { "type": "string" },
            "cvv": { "type": "string" },
            "expiry": { "type": "string" }
          },
          "required": ["method", "card_number", "cvv", "expiry"]
        },
        {
          "type": "object",
          "properties": {
            "method": { "type": "string", "enum": ["bank"] },
            "account_number": { "type": "string" },
            "routing_number": { "type": "string" }
          },
          "required": ["method", "account_number", "routing_number"]
        },
        {
          "type": "object",
          "properties": {
            "method": { "type": "string", "enum": ["paypal"] },
            "email": { "type": "string" }
          },
          "required": ["method", "email"]
        }
      ]
    }
  }
}
```

### TypeScript

From that schema, code generators create a discriminated union type:

```typescript
type PaymentInput =
  | {
      method: "card";
      card_number: string;
      cvv: string;
      expiry: string;
    }
  | {
      method: "bank";
      account_number: string;
      routing_number: string;
    }
  | {
      method: "paypal";
      email: string;
    };
```

Now TypeScript enforces the relationship between `method` and the other fields:

```typescript
const payment: PaymentInput = {
  method: "card",
  card_number: "4242424242424242",
  cvv: "123",
  expiry: "12/25"
}; // ✅ Valid

const invalid: PaymentInput = {
  method: "card",
  email: "user@example.com"  // ❌ Type error!
  // email doesn't exist on card variant
};
```

### Zod (runtime validation + types)

Zod gets a discriminated union schema:

```typescript
import { z } from 'zod';

const PaymentInput = z.discriminatedUnion("method", [
  z.object({
    method: z.literal("card"),
    card_number: z.string(),
    cvv: z.string(),
    expiry: z.string()
  }),
  z.object({
    method: z.literal("bank"),
    account_number: z.string(),
    routing_number: z.string()
  }),
  z.object({
    method: z.literal("paypal"),
    email: z.string().email()
  })
]);

// Infer TypeScript type from Zod schema
type PaymentInput = z.infer<typeof PaymentInput>;
```

This validates at runtime AND provides compile-time types.

### The magic: Type narrowing

With discriminated unions, TypeScript can narrow types based on the discriminator:

```typescript
function processPayment(payment: PaymentInput) {
  switch (payment.method) {
    case "card":
      // TypeScript knows: payment.card_number exists
      console.log(`Processing card ending in ${payment.card_number.slice(-4)}`);
      console.log(payment.email);  // ❌ Compile error! email doesn't exist on card
      break;

    case "bank":
      // TypeScript knows: payment.account_number exists
      console.log(`Processing bank transfer from ${payment.account_number}`);
      console.log(payment.cvv);  // ❌ Compile error! cvv doesn't exist on bank
      break;

    case "paypal":
      // TypeScript knows: payment.email exists
      console.log(`Processing PayPal payment to ${payment.email}`);
      console.log(payment.card_number);  // ❌ Compile error! card_number doesn't exist on paypal
      break;
  }
}
```

TypeScript enforces that you access the right fields for each variant. No runtime checks needed - the compiler guarantees correctness.

### Exhaustiveness checking

TypeScript even enforces that you handle all variants:

```typescript
function processPayment(payment: PaymentInput) {
  switch (payment.method) {
    case "card":
      return processCard(payment);
    case "bank":
      return processBank(payment);
    // Forgot "paypal"!
  }
  // ❌ TypeScript error: Function lacks ending return statement
  //    and return type does not include 'undefined'
}
```

Add the missing case and the error goes away:

```typescript
function processPayment(payment: PaymentInput) {
  switch (payment.method) {
    case "card":
      return processCard(payment);
    case "bank":
      return processBank(payment);
    case "paypal":
      return processPaypal(payment);  // ✅ Now it compiles
  }
}
```

### The complete flow

1. **Backend** - Define discriminated union in contract:
```ruby
param :payment, type: :union, discriminator: :method do
  variant tag: 'card', type: :card_payment
  variant tag: 'bank', type: :bank_payment
end
```

2. **Runtime validation** - Apiwork validates input/output at runtime

3. **Schema endpoint** - Expose contract as OpenAPI/JSON:
```bash
GET /api/v1/.schema/openapi
```

4. **Code generation** - Generate TypeScript/Zod from schema:
```bash
npx @apiwork/codegen --input /api/v1/.schema/openapi --output ./src/api
```

5. **Frontend** - Get compile-time safety:
```typescript
// Editor autocomplete works
// Type errors caught before runtime
// Refactoring is safe
const payment: PaymentInput = { ... };
```

### Real-world example: API responses

Remember how Apiwork auto-generates `ok: true`/`ok: false` responses? That's a discriminated union:

**Backend contract:**
```ruby
output do
  param :ok, type: :boolean, required: true
  param :post, type: :post_schema, required: false
  param :errors, type: :array, of: :error, required: false
end
```

**Generated TypeScript:**
```typescript
type CreatePostResponse =
  | { ok: true; post: Post; meta?: object }
  | { ok: false; errors?: Error[] }
```

**Generated Zod:**
```typescript
const CreatePostResponse = z.discriminatedUnion("ok", [
  z.object({
    ok: z.literal(true),
    post: PostSchema,
    meta: z.object({}).optional()
  }),
  z.object({
    ok: z.literal(false),
    errors: z.array(ErrorSchema).optional()
  })
]);
```

**Frontend usage:**
```typescript
const response = await api.posts.create({ title: "Hello" });

// Runtime validation with Zod
const validated = CreatePostResponse.parse(response);

// Type narrowing with TypeScript
if (validated.ok) {
  // TypeScript knows: post exists, errors doesn't
  console.log(validated.post.id);
} else {
  // TypeScript knows: errors exists, post doesn't
  console.log(validated.errors?.[0]?.message);
}
```

### Why this matters

**Without discriminated unions:**
- Runtime checks everywhere (`if (data.method === 'card' && data.card_number)`)
- No compile-time safety
- Easy to forget to handle cases
- Refactoring is dangerous

**With discriminated unions:**
- Compiler enforces correct field access
- Exhaustiveness checking
- Autocomplete knows what fields exist
- Refactoring is safe (compiler catches errors)

**One contract, validated at runtime in Ruby, enforced at compile-time in TypeScript.** Backend and frontend stay in sync automatically.

## Next steps

- Learn about [Literal Types](literal-types.md) - the building block of discriminated unions
- Explore [Enums](enums.md) for restricting values within a single type
- See [Auto-generated Contracts](introduction.md#auto-generated-contracts) for how Apiwork uses discriminated unions in responses
