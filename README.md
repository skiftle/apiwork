# Apiwork

[![CI](https://github.com/skiftle/apiwork/workflows/CI/badge.svg)](https://github.com/skiftle/apiwork/actions/workflows/ci.yml)

Apiwork is a contract-driven API layer for Rails.

It makes the API boundary explicit by defining _contracts_ that validate incoming requests, shape outgoing responses, and serve as the single
source of truth for runtime behavior and generated artifacts.

Apiwork does not replace Rails. Controllers remain controllers.
ActiveRecord remains ActiveRecord. Apiwork operates at the boundary.

Full documentation: https://apiwork.dev

---

## Core Concepts

### Contracts

A _contract_ defines what your API accepts and returns.

```ruby
contract do
  param :name, Types::String
  param :age,  Types::Integer.optional
end
```

Incoming requests are validated before your domain logic runs.\
Invalid requests are rejected with structured errors.

---

### Representations

For ActiveRecord-backed endpoints, _representations_ describe how a
model appears through the API by building on metadata Rails already
knows: column types, enums, nullability, and associations.

From this, Apiwork derives request validation, filtering, sorting,
pagination, and response shaping.

The database remains the source of truth. The API boundary reflects it.

---

### Adapters

_Adapters_ encode API conventions such as filtering behavior, pagination
strategy, and nested writes.

Apiwork ships with a built-in adapter and allows custom adapters to
encode domain-specific or performance-specific conventions.

---

## Generated Artifacts

Because contracts are structured and introspectable, Apiwork can
generate:

- OpenAPI specifications
- TypeScript types
- Zod schemas

These are derived from the same definitions that validate requests at
runtime.

What runs in production is what your clients compile against.

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
