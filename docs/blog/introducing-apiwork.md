---
title: Introducing Apiwork
date: 2025-12-10
author: Joakim
---

# Introducing Apiwork

We're excited to announce **Apiwork**, a new approach to building type-safe APIs in Ruby on Rails.

## The Problem

Building APIs in Rails has always been straightforward, but ensuring type safety across the stack has been challenging. You write your endpoints, serialize your data, and hope that your frontend and backend stay in sync.

## Our Solution

Apiwork provides a declarative way to define your API contracts with automatic type generation for TypeScript, Zod schemas, and OpenAPI specifications.

```ruby
class InvoiceContract < Apiwork::Contract
  attribute :id, :integer
  attribute :total, :decimal
  attribute :status, :string, enum: %w[draft sent paid]
  attribute :line_items, array: LineItemContract
end
```

From this single definition, Apiwork generates:

- **TypeScript interfaces** for your frontend
- **Zod schemas** for runtime validation
- **OpenAPI specs** for documentation

## What's Next

We're working on:

- Better integration with Rails generators
- Support for more output formats
- Improved error messages and developer experience

Stay tuned for more updates!
