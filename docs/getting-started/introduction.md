---
order: 1
---

# Introduction

Apiwork is built around a simple idea: everything that enters or leaves your API should pass through a contract.

A contract defines the exact shape of a request and the exact shape of a response. If incoming data doesn't match, Apiwork rejects it. If outgoing data violates the contract, Apiwork alerts you in development.

## Why Contracts?

Inside Rails, Ruby's flexibility works in your favor — conventions make explicit types feel unnecessary. But once data crosses the API boundary and reaches a TypeScript, Swift, or Kotlin client, those conventions vanish.

Contracts fix this:
- Specify exactly what the API accepts and returns
- Validate incoming data before it touches your models
- Ensure predictable, stable responses for any client

And because contracts are the single source of truth, Apiwork generates OpenAPI specs, Zod schemas, and TypeScript types from them automatically.

## How It Fits

Apiwork focuses on the boundary layer. It steps in before your controller runs to prepare clean, validated input, and steps in after to shape the output. Everything inside — your models, callbacks, domain logic — stays pure Rails.

You write your own controllers. You use ActiveRecord as usual. Apiwork standardizes what goes in and what comes out.

## What's Next

- [Installation](./installation.md) — add Apiwork to your project
- [Core Concepts](./core-concepts.md) — understand API definitions, contracts, and schemas
- [Quick Start](./quick-start.md) — build your first endpoint
