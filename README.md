# Apiwork

[![CI](https://github.com/skiftle/apiwork/workflows/CI/badge.svg)](https://github.com/skiftle/apiwork/actions/workflows/ci.yml)

# Apiwork

Apiwork is a contract-driven API layer for Rails.

It helps you define your API boundary explicitly instead of spreading structure across controllers, serializers, validation logic, and documentation. You define the contract once — and that definition validates requests, shapes responses, and can generate OpenAPI specs and typed client artifacts.

Apiwork does not replace Rails. It works alongside it. Controllers stay controllers. ActiveRecord stays ActiveRecord. Domain logic stays where it belongs.

---

## Core Concepts

### Contracts

A contract defines what your API accepts and returns.

Incoming requests are validated against the contract before reaching your application code. Invalid input is rejected with structured errors at the boundary.

There is no separate validation layer and no manual type checking in controllers. The contract executes at runtime.

You can define contracts entirely by hand.

---

### Representations

For endpoints backed by ActiveRecord models, representations reduce repetition.

A representation describes how a model is exposed through the API — which attributes are readable, which are writable, and how associations are handled.

It builds on metadata Rails already knows from your models and database: column types, enums, nullability, and associations.

The database remains the source of truth. The API boundary reflects it intentionally.

---

### Adapters

Adapters encode API conventions.

They define how filtering works, how pagination behaves, how nested writes are processed, and how related records are handled.

Apiwork ships with a built-in adapter that supports:

- Operator-based filtering
- Sorting
- Cursor and offset pagination
- Nested writes
- Single-table inheritance
- Polymorphic associations

You can implement your own adapter to capture different conventions or performance strategies.

---

## Generated Specifications

Because contracts and representations are structured and introspectable, Apiwork can generate:

- OpenAPI specifications
- TypeScript types
- Zod schemas

These artifacts are derived from the same definitions that validate requests at runtime.

There is no parallel schema layer and no drift between validation and generated types.

---

## Why Use Apiwork?

Rails is dynamic and expressive inside the application.  
Modern clients are typed and explicit at the boundary.

Apiwork strengthens that boundary without changing your architecture.

It gives you:

- Explicit and predictable APIs
- Runtime validation
- Consistent conventions
- Generated typed artifacts
- A single source of truth

All while staying aligned with Rails conventions.

---

## Installation

```bash
bundle add apiwork
```

---

## Documentation

For guides, advanced usage, and architectural details, see:

https://apiwork.dev

---

## Status

Apiwork is under active development.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add apiwork
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install apiwork
```

## Usage

Read more on [apiwork.dev](https://apiwork.dev).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skiftle/apiwork.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
