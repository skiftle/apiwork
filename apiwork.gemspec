# frozen_string_literal: true

require_relative 'lib/apiwork/version'

Gem::Specification.new do |s|
  s.name     = 'apiwork'
  s.version  = Apiwork::VERSION
  s.authors  = ['skiftle']
  s.summary  = 'The craft of API design'
  s.homepage = 'https://apiwork.dev'
  s.license  = 'MIT'

  s.required_ruby_version = '>= 3.1'

  s.add_dependency 'rails', '>= 8.0'
  s.add_dependency 'zeitwerk', '~> 2.6'

  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-rails', '~> 6.0'
  s.add_development_dependency 'rubocop', '~> 1.0'
  s.add_development_dependency 'rubocop-rails', '~> 2.0'
  s.add_development_dependency 'rubocop-rspec', '~> 3.0'
  s.add_development_dependency 'sqlite3', '~> 2.0'

  s.files = Dir['{app,lib}/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']

  s.metadata['changelog_uri']         = 'https://github.com/skiftle/apiwork/blob/main/CHANGELOG.md'
  s.metadata['homepage_uri']          = 'https://apiwork.dev'
  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['source_code_uri']       = 'https://github.com/skiftle/apiwork'
end
