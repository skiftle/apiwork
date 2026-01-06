---
order: 1
---

# Introduction

Apiwork lets you define your API once. Everything else builds on that definition.

Apiwork adds a contract layer at the boundary of your app. Requests are validated against that contract, and responses are shaped by it. Data that matches flows through. Data that doesn't is rejected.

## Behavior follows structure

From that contract, common behavior follows automatically: filtering, sorting, pagination, sideloading, N+1 prevention, and nested writes. This logic follows from the structure. The same structure generates API specifications and documentation, keeping them aligned with behavior.

## Rails-native by design

Apiwork follows Rails conventions. You still write controllers. It builds on Rails rather than replacing it.

## No duplicated domain knowledge

Apiwork avoids repeating what Rails already knows. Rails — and the database beneath it — already encodes much of your domain: attributes, types, enum values, associations, defaults, and nullability. Apiwork builds on that knowledge instead of duplicating it. The database becomes the source of truth, and the API stays aligned with it automatically.

## Next Steps

The following guides show how this works in practice.

- [Installation](./installation.md)
- [Core Concepts](./core-concepts.md)
- [Quick Start](./quick-start.md)
