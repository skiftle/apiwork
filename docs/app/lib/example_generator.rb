# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'

class ExampleGenerator
  EXAMPLES_DIR = Rails.root.join('../examples')

  def self.run
    new.generate_all
  end

  def generate_all
    Rails.logger.debug 'Generating documentation examples...'

    FileUtils.rm_rf(EXAMPLES_DIR)
    FileUtils.mkdir_p(EXAMPLES_DIR)

    Apiwork::API.all.each do |api| # rubocop:disable Rails/FindEach
      generate_for_api(api)
    end

    Rails.logger.debug 'Done!'
  end

  private

  def generate_for_api(api)
    namespace = api.metadata.path.delete_prefix('/')
    output_dir = EXAMPLES_DIR.join(namespace)
    FileUtils.mkdir_p(output_dir)

    Rails.logger.debug "  Generating: #{namespace}/"

    write_typescript(api, output_dir)
    write_zod(api, output_dir)
    write_openapi(api, output_dir)
    write_introspection(api, output_dir)
  end

  def write_typescript(api, dir)
    content = Apiwork::Spec::Typescript.generate(path: api.metadata.path)
    File.write(dir.join('typescript.ts'), content)
  end

  def write_zod(api, dir)
    content = Apiwork::Spec::Zod.generate(path: api.metadata.path)
    File.write(dir.join('zod.ts'), content)
  end

  def write_openapi(api, dir)
    content = Apiwork::Spec::Openapi.generate(path: api.metadata.path)
    File.write(dir.join('openapi.yml'), content.to_yaml)
  end

  def write_introspection(api, dir)
    content = api.introspect
    File.write(dir.join('introspection.json'), JSON.pretty_generate(content))
  end
end
