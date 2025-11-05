# frozen_string_literal: true

require_relative 'lib/apiwork/version'

Gem::Specification.new do |spec|
  spec.name                  = 'apiwork'
  spec.version               = Apiwork::VERSION
  spec.summary               = 'apiwork — the craft of API design.'
  spec.description           = 'Rails-native framework for building APIs with resources, contracts and routes.'
  spec.license               = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.homepage              = 'https://apiwork.dev'
  spec.authors               = ['apiwork contributors']
  spec.email                 = []

  spec.metadata['bug_tracker_uri']       = 'https://github.com/skiftle/apiwork/issues'
  spec.metadata['changelog_uri']         = 'https://github.com/skiftle/apiwork/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri']     = 'https://apiwork.dev/docs'
  spec.metadata['homepage_uri']          = 'https://apiwork.dev'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri']       = 'https://github.com/skiftle/apiwork'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = []
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'rails', '>= 7.0', '< 9.0'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # Development dependencies - Testing
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 6.0'
  spec.add_development_dependency 'sqlite3', '~> 2.0'

  # Development dependencies - Code Quality
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rails', '~> 2.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
end
