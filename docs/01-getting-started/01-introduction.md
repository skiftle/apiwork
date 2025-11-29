# Introduction

Apiwork is a contract-driven, schema-based API framework for Rails.

It builds on Rails foundationsespecially ActiveRecordand adds a structured layer on top. The idea is not to fight Rails, but to extend it. You still use controllers, models, and everything else you're used to.

## Why Contract-Driven?

A contract-driven API provides two core benefits:

**Safety**  only what's explicitly defined is accepted.

**Predictability**  input, output, and behavior are clearly specified.

When the contract is the single source of truth, you can generate multiple specifications automatically from the same definition: OpenAPI, Zod, TypeScript. This fits modern ecosystems where typed clients are standard. Apiwork delivers these out of the box.

## Schema as Source of Truth

Apiwork leverages ActiveRecord as the underlying source of truth.

Through the schema, the system automatically inherits information from the model:

- Data types
- Enum definitions
- Associations
- Validatable structure

In practice, the database via ActiveRecord becomes the raw source of truth, and Apiwork uses that information in its contracts and specifications.
