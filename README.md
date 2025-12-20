# Apiwork

[![CI](https://github.com/skiftle/apiwork/workflows/CI/badge.svg)](https://github.com/skiftle/apiwork/actions/workflows/ci.yml)

Apiwork provides a contract-driven API layer for Rails:

- **API Definitions** declare resources, mount points, and global configuration like key format.
- **Contracts** define the shape of requests and responses with typed parameters and validation.
- **Schemas** connect contracts to ActiveRecord models, inferring types from your database schema.
- **Runtime** handles filtering, sorting, pagination, and includes based on what contracts allow.
- **Specs** generate OpenAPI, TypeScript, and Zod output from the same contract definitions.

Types flow from your database through contracts to generated specs. You define structure once — behaviour and documentation follow.

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
