# frozen_string_literal: true

require_relative "lib/apiwork/version"

Gem::Specification.new do |spec|
  spec.name                  = "apiwork"
  spec.version               = Apiwork::VERSION
  spec.summary               = "apiwork — the craft of API design."
  spec.description           = "Rails-native framework for building APIs with resources, contracts and routes."
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.homepage              = "https://apiwork.dev"
  spec.authors               = ["apiwork contributors"]
  spec.email                 = []

  spec.metadata["homepage_uri"]        = "https://apiwork.dev"
  spec.metadata["source_code_uri"]     = "https://github.com/skiftle/apiwork"
  spec.metadata["changelog_uri"]       = "https://github.com/skiftle/apiwork/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"]     = "https://github.com/skiftle/apiwork/issues"
  spec.metadata["documentation_uri"]   = "https://apiwork.dev/docs"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Files to include (välj EN av varianterna nedan)

  # A) Git-baserad (bra när repo är initierat)
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  # B) Dir-baserad (avkommentera dessa rader om du vill slippa git-krav)
  # spec.files = Dir[
  #   "lib/**/*",
  #   "README*",
  #   "LICENSE*",
  #   "CHANGELOG*",
  #   "apiwork.gemspec"
  # ]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
