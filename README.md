# Apiwork

[![CI](https://github.com/skiftle/apiwork/workflows/CI/badge.svg)](https://github.com/skiftle/apiwork/actions/workflows/ci.yml)

Apiwork is a contract-driven API layer for Rails.

It helps you define your API boundary explicitly instead of spreading structure across controllers, serializers, validation logic, and documentation. You define the contract once — and that definition validates requests, shapes responses, and can generate OpenAPI specs and typed client artifacts.

Apiwork does not replace Rails. It works alongside it. Controllers stay controllers. ActiveRecord stays ActiveRecord. Domain logic stays where it belongs.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skiftle/apiwork.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
