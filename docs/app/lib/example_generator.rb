# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'

class ExampleGenerator
  PUBLIC_DIR = Rails.root.join('public')
  EXAMPLES_DIR = Rails.root.join('../examples')
  CONFIG_DIR = Rails.root.join('config/examples')

  def self.run
    new.generate_all
  end

  def generate_all
    Rails.logger.debug 'Generating documentation examples...'

    FileUtils.rm_rf(EXAMPLES_DIR)
    FileUtils.mkdir_p(EXAMPLES_DIR)

    examples = []

    each_example do |namespace, metadata|
      generate_for_namespace(namespace, metadata)
      examples << metadata.merge(namespace:)
    end

    generate_index(examples)

    Rails.logger.debug 'Done!'
  end

  private

  def each_example
    Dir.glob(CONFIG_DIR.join('*.yml')).sort.each do |config_file|
      namespace = File.basename(config_file, '.yml')
      metadata = YAML.load_file(config_file).symbolize_keys
      yield namespace, metadata
    end
  end

  def generate_for_namespace(namespace, metadata)
    locale_key = namespace.dasherize
    output_dir = PUBLIC_DIR.join(locale_key)

    FileUtils.rm_rf(output_dir)
    FileUtils.mkdir_p(output_dir)

    Rails.logger.debug "  Generating: #{locale_key}/"

    api = Apiwork::API.all.find { |a| a.metadata.locale_key == locale_key }
    return unless api

    write_specs(api, output_dir)
    write_markdown(namespace, locale_key, metadata)
  end

  def write_specs(api, dir)
    write_typescript(api, dir)
    write_zod(api, dir)
    write_openapi(api, dir)
    write_introspection(api, dir)
  end

  def write_typescript(api, dir)
    content = Apiwork::Spec::Typescript.generate(api.metadata.path)
    File.write(dir.join('typescript.ts'), content)
  end

  def write_zod(api, dir)
    content = Apiwork::Spec::Zod.generate(api.metadata.path)
    File.write(dir.join('zod.ts'), content)
  end

  def write_openapi(api, dir)
    content = Apiwork::Spec::Openapi.generate(api.metadata.path)
    File.write(dir.join('openapi.yml'), content.to_yaml)
  end

  def write_introspection(api, dir)
    content = api.introspect
    File.write(dir.join('introspection.json'), JSON.pretty_generate(content))
  end

  def write_markdown(namespace, locale_key, metadata)
    content = build_markdown(namespace, locale_key, metadata)
    slug = metadata[:title].parameterize
    File.write(EXAMPLES_DIR.join("#{slug}.md"), content)
  end

  def build_markdown(namespace, locale_key, metadata)
    sections = []

    sections << frontmatter(metadata)
    sections << "# #{metadata[:title]}"
    sections << metadata[:description]

    sections << api_section(namespace)
    sections << models_section(namespace)
    sections << schemas_section(namespace)
    sections << contracts_section(namespace)
    sections << controllers_section(namespace)
    sections << generated_output_section(locale_key)

    sections.compact.join("\n\n")
  end

  def frontmatter(metadata)
    "---\norder: #{metadata[:order]}\n---"
  end

  def api_section(namespace)
    file = "config/apis/#{namespace}.rb"
    return unless file_exists?(file)

    <<~MD.strip
      ## API Definition

      <small>`#{file}`</small>

      <<< @/app/#{file}
    MD
  end

  def models_section(namespace)
    files = files_in("app/models/#{namespace}")
    return if files.empty?

    content = ["## Models"]
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def schemas_section(namespace)
    files = files_in("app/schemas/#{namespace}")
    return if files.empty?

    content = ["## Schemas"]
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def contracts_section(namespace)
    files = files_in("app/contracts/#{namespace}")
    return if files.empty?

    content = ["## Contracts"]
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def controllers_section(namespace)
    files = files_in("app/controllers/#{namespace}")
    return if files.empty?

    content = ["## Controllers"]
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def generated_output_section(locale_key)
    <<~MD.strip
      ---

      ## Generated Output

      <details>
      <summary>Introspection</summary>

      <<< @/app/public/#{locale_key}/introspection.json

      </details>

      <details>
      <summary>TypeScript</summary>

      <<< @/app/public/#{locale_key}/typescript.ts

      </details>

      <details>
      <summary>Zod</summary>

      <<< @/app/public/#{locale_key}/zod.ts

      </details>

      <details>
      <summary>OpenAPI</summary>

      <<< @/app/public/#{locale_key}/openapi.yml

      </details>
    MD
  end

  def file_block(path)
    <<~MD.strip
      <small>`#{path}`</small>

      <<< @/app/#{path}
    MD
  end

  def files_in(dir)
    full_path = Rails.root.join(dir)
    return [] unless File.directory?(full_path)

    Dir.glob(full_path.join('*.rb')).sort.map do |file|
      "#{dir}/#{File.basename(file)}"
    end
  end

  def file_exists?(path)
    File.exist?(Rails.root.join(path))
  end

  def generate_index(examples)
    sorted = examples.sort_by { |e| e[:order] }

    rows = sorted.map do |example|
      slug = example[:title].parameterize
      "| [#{example[:title]}](./#{slug}.md) | #{example[:description]} |"
    end

    content = <<~MD
      ---
      order: 99
      ---

      # Examples

      Complete working examples showing Apiwork features with full generated output.

      Each example includes:
      - API definition, models, schemas, contracts, and controllers
      - Generated TypeScript types
      - Generated Zod validators
      - Generated OpenAPI spec
      - Introspection output

      ## Available Examples

      | Example | Description |
      |---------|-------------|
      #{rows.join("\n")}
    MD

    File.write(EXAMPLES_DIR.join('index.md'), content)
  end
end
