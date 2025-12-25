---
order: 4
---

# Format

The format is designed to be as compact as possible. Defaults are omitted, empty values stripped, and only meaningful data remains. No noise, no placeholders, no redundant metadata.

Compact output keeps diffs small, makes generators reliable, and reduces cognitive load when debugging.

---

## Example

```json
{
  "path": "/api/v1",
  "info": { "title": "My API", "version": "1.0.0" },
  "resources": {
    "posts": {
      "path": "posts",
      "actions": {
        "index": {
          "method": "GET",
          "path": "/",
          "response": {
            "body": { "type": "array", "of": "post" }
          }
        }
      }
    }
  },
  "types": {
    "post": { "type": "object", "shape": { "id": { "type": "integer" } } }
  },
  "enums": { "status": { "values": ["draft", "published", "archived"] } },
  "error_codes": {
    "bad_request": { "status": 400, "description": "Bad Request" }
  }
}
```

A simple string becomes:

```json
{ "type": "string" }
```

---

## Omitted Values

| Property      | Omitted when   |
| ------------- | -------------- |
| `optional`    | `false`        |
| `nullable`    | `false`        |
| `default`     | `nil`          |
| `description` | `nil` or empty |
| `deprecated`  | `false`        |

Empty objects and arrays are also omitted.

---

## Primitive Types

| Type               | Meaning            | `min`/`max` | Format                 |
| ------------------ | ------------------ | ----------- | ---------------------- |
| `string`           | text               | length      | `email`, `uri`, `uuid` |
| `integer`          | whole number       | value       | -                      |
| `float`, `decimal` | decimal number     | value       | -                      |
| `boolean`          | true/false         | -           | -                      |
| `datetime`         | ISO 8601 timestamp | -           | `date-time`            |
| `date`             | ISO 8601 date      | -           | `date`                 |
| `uuid`             | UUID string        | -           | `uuid`                 |

---

## Container Types

| Type           | Description                 | Required fields |
| -------------- | --------------------------- | --------------- |
| `array`        | ordered list                | `of`            |
| `object`       | structured fields           | `shape`         |
| `union`        | multiple possible types     | `variants`      |
| `literal`      | exact value                 | `value`         |
| custom type    | reference to a defined type | -               |
| enum reference | reference to a defined enum | -               |

---

## Field Properties

| Property        | Meaning                      |
| --------------- | ---------------------------- |
| `type`          | field type                   |
| `optional`      | omitted in requests          |
| `nullable`      | can be `null`                |
| `default`       | used when omitted            |
| `description`   | human-readable               |
| `example`       | documentation-only           |
| `format`        | format hint                  |
| `deprecated`    | field should not be used     |
| `min` / `max`   | numeric or length constraint |
| `enum`          | allowed values               |
| `of`            | array element type           |
| `shape`         | nested fields                |
| `variants`      | union alternatives           |
| `discriminator` | union routing field          |
| `tag`           | union variant identifier     |
| `value`         | literal                      |
| `as`            | Rails/JSON alias             |
