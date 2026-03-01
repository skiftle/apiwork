<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/public/logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="docs/public/logo-light.svg">
  <img alt="Apiwork" src="docs/public/logo-light.svg" width="280">
</picture>

[![Gem Version](https://img.shields.io/gem/v/apiwork)](https://rubygems.org/gems/apiwork)
[![CI](https://github.com/skiftle/apiwork/actions/workflows/ci.yml/badge.svg)](https://github.com/skiftle/apiwork/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

![OpenAPI](https://img.shields.io/badge/OpenAPI-exports-6BA539?logo=openapiinitiative&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-exports-3178C6?logo=typescript&logoColor=white)
![Zod](https://img.shields.io/badge/Zod-exports-3068B7?logo=zod&logoColor=white)

Typed APIs for Rails.

Apiwork lets you define your API once and derive validation, serialization, querying, and typed exports from the same definition.

It integrates with Rails rather than replacing it. Controllers, ActiveRecord models, and application logic remain unchanged.

See https://apiwork.dev for full documentation.

---

## Overview

Apiwork introduces an explicit, typed boundary to a Rails application.

From a single definition, it provides:

- Runtime request validation
- Response serialization
- Filtering, sorting, and pagination
- Nested writes
- OpenAPI specification
- Generated TypeScript and Zod types

The same structures that validate requests in production are used to generate client artifacts. There is no parallel schema layer.

---

## Example

A representation describes how a model appears through the API:

```ruby
class InvoiceRepresentation < Apiwork::Representation::Base
  attribute :id
  attribute :number, writable: true, filterable: true, sortable: true
  attribute :status, filterable: true
  attribute :issued_on, writable: true, sortable: true

  belongs_to :customer, filterable: true
  has_many :lines, writable: true
end
```

Types and nullability are inferred from ActiveRecord metadata.

From this definition, Apiwork derives:

- Typed request contracts
- Response serializers
- Query parameters for filtering and sorting
- Offset or cursor-based pagination
- Nested write handling
- OpenAPI and client type exports

A minimal controller:

```ruby
def index
  expose Invoice.all
end

def create
  expose Invoice.create(contract.body[:invoice])
end
```

`contract.body` contains validated parameters.  
`expose` serializes the response according to the representation.

---

## Querying

Filtering and sorting are declared on attributes and associations.

Example query parameters:

```
?filter[status][eq]=sent
?sort[issued_on]=desc
```

Operators are typed and validated. Generated client types reflect the same structure.

---

## Standalone Contracts

Representations are optional. Contracts can be defined independently of ActiveRecord for webhooks, external APIs, or custom request and response shapes.

---

## Installation

Add to your Gemfile:

```bash
bundle add apiwork
```

Then run:

```bash
rails generate apiwork:install
```

---

## Status

Under active development.

## License

MIT
