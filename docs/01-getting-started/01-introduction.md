# Introduction

Apiwork is a contract-driven, schema-powered API framework for Rails.

It builds directly on Rails foundations — especially ActiveRecord — and adds a structured layer for defining and maintaining APIs. The goal isn’t to rethink Rails or replace its patterns, but to extend them in a way that feels completely natural. You still write controllers, models and resources the same way; Apiwork simply gives your API a clear, explicit definition that Rails has never formalized on its own.

## Why Contract-Driven?

A contract-driven API brings several major advantages:

**Safety** — only the data you explicitly define is allowed in.  
**Predictability** — requests, responses and behavior follow a consistent structure.  
**Typed clients** — because contracts describe the API precisely, Apiwork can generate OpenAPI, Zod and TypeScript clients directly from the same source. Typed clients are standard today, and Apiwork supports them out of the box.  
**Accurate documentation** — docs are generated from the same contracts that drive the server, so they never drift or become outdated.  
**Consistency across the whole system** — controllers, specs, clients and schemas all point to one single definition.

Another major strength of this approach is consolidation. Rails developers often rely on a mix of serializers, presenters, documentation tools, validation gems, pagination gems, filtering gems and manually written client types. Apiwork unifies all of this into one coherent system. You no longer need five or six gems that each solve one part of the puzzle. The pieces inside Apiwork are designed to work seamlessly together, without conflicts, glue code or integration friction.

## Schema as Source of Truth

Apiwork also builds on ActiveRecord as its foundation. When you use schemas, Apiwork automatically reads structural information directly from your models:

- database column types
- enums
- associations
- nullability and basic constraints

In practice, the database — through ActiveRecord — becomes the raw source of truth. Apiwork turns that information into structured metadata that flows into contracts, controllers, adapter logic and generated clients. Schemas are optional, but when used, they unlock a powerful, Rails-friendly workflow with minimal configuration and maximum consistency.

Together, the API definition, contracts and schemas create a unified model for your entire API. Instead of stitching together multiple gems that each solve one piece of the picture, Apiwork provides a single, tightly integrated layer that keeps your API predictable, documented and type-safe from end to end.

Continue to **Core Concepts** to see how these pieces fit together in practice.
