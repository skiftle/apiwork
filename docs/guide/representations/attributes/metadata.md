---
order: 7
---

# Metadata

Documentation options for API exports and client generation. These options affect generated OpenAPI, TypeScript, and Zod output but have no effect on runtime behavior.

## description

Human-readable description for API documentation:

```ruby
attribute :status, description: "Current publication status"
```

## example

Example value shown in generated exports:

```ruby
attribute :email, example: "user@example.com"
attribute :created_at, example: "2024-01-15T10:30:00Z"
```

## deprecated

Mark an attribute as deprecated:

```ruby
attribute :legacy_id, deprecated: true
```

## format

Type-specific format hints for validation and client generation:

```ruby
attribute :email, format: :email
attribute :website, format: :url
attribute :uuid, format: :uuid
attribute :ip_address, format: :ipv4
```

| Format | OpenAPI | Zod |
|--------|---------|-----|
| `:email` | `format: email` | `z.email()` |
| `:uuid` | `format: uuid` | `z.uuid()` |
| `:url` | `format: uri` | `z.url()` |
| `:date` | `format: date` | `z.iso.date()` |
| `:datetime` | `format: date-time` | `z.iso.datetime()` |
| `:ipv4` | `format: ipv4` | `z.ipv4()` |
| `:ipv6` | `format: ipv6` | `z.ipv6()` |
| `:password` | `format: password` | `z.string()` |
| `:hostname` | `format: hostname` | `z.string()` |
