# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'yaml'
require_relative 'request_runner'

class ExampleGenerator
  PUBLIC_DIR = Rails.root.join('public')
  EXAMPLES_DIR = Rails.root.join('../examples')
  CONFIG_DIR = Rails.root.join('config/examples')

  def self.run
    new.generate_all
  end

  def generate_all
    Rails.logger.debug 'Generating documentation examples...'

    eager_load_schemas

    temp_dir = Rails.root.join('tmp/docs_generation')
    temp_public = temp_dir.join('public')
    temp_examples = temp_dir.join('examples')

    FileUtils.rm_rf(temp_dir)
    FileUtils.mkdir_p(temp_public)
    FileUtils.mkdir_p(temp_examples)

    examples = []

    each_api do |api_class, namespace, metadata|
      generate_for_api(api_class, namespace, metadata, temp_public, temp_examples)
      examples << metadata.merge(namespace:)
    end

    generate_index(examples, temp_examples)

    swap_output(temp_public, temp_examples)

    Rails.logger.debug 'Done!'
  ensure
    FileUtils.rm_rf(temp_dir) if temp_dir
  end

  def swap_output(temp_public, temp_examples)
    generated_dirs.each do |dir|
      dest = PUBLIC_DIR.join(dir)
      FileUtils.rm_rf(dest)
      FileUtils.mv(temp_public.join(dir), dest) if File.exist?(temp_public.join(dir))
    end

    FileUtils.rm_rf(EXAMPLES_DIR)
    FileUtils.mv(temp_examples, EXAMPLES_DIR)
  end

  def generated_dirs
    Apiwork::API.all.map do |api_class|
      api_class.path.delete_prefix('/').underscore.dasherize
    end
  end

  private

  def eager_load_schemas
    Dir.glob(Rails.root.join('app/schemas/**/*.rb')).sort.each do |file|
      relative = file.sub(Rails.root.join('app/schemas/').to_s, '')
      class_name = relative.sub(/\.rb$/, '').camelize

      begin
        class_name.constantize
      rescue NameError
        # Schema file doesn't define expected class, skip
      end
    end
  end

  def each_api
    Apiwork::API.all.sort_by(&:path).each do |api_class|
      namespace = api_class.path.delete_prefix('/').underscore
      metadata = metadata_for(namespace)
      yield api_class, namespace, metadata
    end
  end

  def metadata_for(namespace)
    yml_path = CONFIG_DIR.join("#{namespace}.yml")

    if File.exist?(yml_path)
      YAML.load_file(yml_path).deep_symbolize_keys
    else
      {
        description: 'Complete example with API, models, schemas, contracts, and controllers.',
        order: 999,
        title: namespace.humanize.titleize,
      }
    end
  end

  def generate_for_api(api_class, namespace, metadata, temp_public, temp_examples)
    locale_key = namespace.dasherize
    output_dir = temp_public.join(locale_key)

    FileUtils.mkdir_p(output_dir)

    Rails.logger.debug "  Generating: #{locale_key}/"

    write_specs(api_class, output_dir)
    write_requests(namespace, output_dir, metadata[:scenarios]) if metadata[:scenarios]
    write_markdown(namespace, locale_key, metadata, temp_examples, temp_public)
  end

  def write_specs(api_class, dir)
    write_typescript(api_class, dir)
    write_zod(api_class, dir)
    write_openapi(api_class, dir)
    write_introspection(api_class, dir)
  end

  def write_typescript(api_class, dir)
    content = Apiwork::Export::TypeScript.generate(api_class.path)
    File.write(dir.join('typescript.ts'), content)
  end

  def write_zod(api_class, dir)
    content = Apiwork::Export::Zod.generate(api_class.path)
    File.write(dir.join('zod.ts'), content)
  end

  def write_openapi(api_class, dir)
    content = Apiwork::Export::OpenAPI.generate(api_class.path, format: :yaml)
    File.write(dir.join('openapi.yml'), content)
  end

  def write_introspection(api_class, dir)
    content = api_class.introspect.to_h
    File.write(dir.join('introspection.json'), JSON.pretty_generate(content))
  end

  def write_requests(namespace, dir, scenarios)
    Rails.logger.debug '    Running request scenarios...'

    requests_dir = dir.join('requests')
    FileUtils.mkdir_p(requests_dir)

    runner = RequestRunner.new(namespace, scenarios)
    results = runner.run_all

    results.each do |action, data|
      File.write(requests_dir.join("#{action}.json"), JSON.pretty_generate(data))
    end
  end

  def write_markdown(namespace, locale_key, metadata, temp_examples, temp_public)
    content = build_markdown(namespace, locale_key, metadata, temp_public)
    slug = metadata[:title].parameterize
    File.write(temp_examples.join("#{slug}.md"), content)
  end

  def build_markdown(namespace, locale_key, metadata, temp_public)
    parts = []

    parts << frontmatter(metadata)
    parts << "# #{metadata[:title]}"
    parts << metadata[:description]
    parts << sections_content(namespace, metadata)
    parts << requests_section(locale_key, metadata[:scenarios], temp_public)
    parts << generated_output_section(locale_key)

    parts.compact.join("\n\n")
  end

  def sections_content(namespace, metadata)
    return legacy_sections(namespace) unless metadata[:sections]

    metadata[:sections].map { |s| section_block(s[:title], s[:files]) }.compact.join("\n\n")
  end

  def section_block(title, files)
    return nil if files.blank?

    content = ["## #{title}"]
    files.each do |file|
      next unless file_exists?(file)

      content << file_block(file)
      content << database_table_details(file) if file.include?('/models/')
    end
    content.compact.join("\n\n")
  end

  def database_table_details(file)
    model_name = File.basename(file, '.rb')
    namespace = file.split('/')[-2]
    table_name = "#{namespace}_#{model_name.pluralize}"

    schema_details_for_table(table_name)
  end

  def legacy_sections(namespace)
    [
      api_section(namespace),
      models_section(namespace),
      schemas_section(namespace),
      contracts_section(namespace),
      controllers_section(namespace),
    ].compact.join("\n\n")
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

      <<< @/playground/#{file}
    MD
  end

  def models_section(namespace)
    files = files_in("app/models/#{namespace}")
    return if files.empty?

    content = ['## Models']
    files.each do |file|
      model_name = File.basename(file, '.rb')
      table_name = "#{namespace}_#{model_name.pluralize}"

      content << file_block(file)
      content << schema_details_for_table(table_name)
    end
    content.compact.join("\n\n")
  end

  def schema_details_for_table(table_name)
    return unless table_exists?(table_name)

    cols = ActiveRecord::Base.connection.columns(table_name)

    lines = []
    lines << '<details>'
    lines << '<summary>Database Table</summary>'
    lines << ''
    lines << '| Column | Type | Nullable | Default |'
    lines << '|--------|------|----------|---------|'

    cols.each do |col|
      type = column_type(col)
      nullable = col.null ? '✓' : ''
      default = col.default.present? ? col.default.to_s : ''
      lines << "| #{col.name} | #{type} | #{nullable} | #{default} |"
    end

    lines << ''
    lines << '</details>'

    lines.join("\n")
  end

  def table_exists?(table_name)
    ActiveRecord::Base.connection.table_exists?(table_name)
  end

  def column_type(col)
    return 'string' if col.name == 'id' || col.name.end_with?('_id')

    col.type.to_s
  end

  def schemas_section(namespace)
    files = files_in("app/schemas/#{namespace}")
    return if files.empty?

    content = ['## Schemas']
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def contracts_section(namespace)
    files = files_in("app/contracts/#{namespace}")
    return if files.empty?

    content = ['## Contracts']
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def controllers_section(namespace)
    files = files_in("app/controllers/#{namespace}")
    return if files.empty?

    content = ['## Controllers']
    files.each do |file|
      content << file_block(file)
    end
    content.join("\n\n")
  end

  def requests_section(locale_key, scenarios, temp_public)
    return unless scenarios

    requests_dir = temp_public.join(locale_key, 'requests')
    return unless File.directory?(requests_dir)

    content = ['---', '', '## Request Examples']

    sorted = scenarios.sort_by { |s| s[:order] || 999 }
    sorted.each do |scenario|
      slug = scenario[:title].parameterize
      file_path = requests_dir.join("#{slug}.json")
      next unless File.exist?(file_path)

      data = JSON.parse(File.read(file_path), symbolize_names: true)
      content << request_example_block(scenario[:title], data)
    end

    content.join("\n\n")
  end

  def request_example_block(action, data)
    request = data[:request]
    response = data[:response]

    method = request[:method]
    path = request[:path]
    status = response[:status]

    parts = []
    parts << '<details>'
    parts << "<summary>#{action}</summary>"
    parts << ''

    parts << '**Request**'
    parts << ''
    parts << if request[:body]
               "```http\n#{method} #{path}\nContent-Type: application/json\n\n#{JSON.pretty_generate(request[:body])}\n```"
             else
               "```http\n#{method} #{path}\n```"
             end

    parts << ''
    parts << "**Response** `#{status}`"
    parts << ''
    parts << "```json\n#{JSON.pretty_generate(response[:body])}\n```" if response[:body]

    parts << ''
    parts << '</details>'

    parts.join("\n")
  end

  def generated_output_section(locale_key)
    <<~MD.strip
      ---

      ## Generated Output

      <details>
      <summary>Introspection</summary>

      <<< @/playground/public/#{locale_key}/introspection.json

      </details>

      <details>
      <summary>TypeScript</summary>

      <<< @/playground/public/#{locale_key}/typescript.ts

      </details>

      <details>
      <summary>Zod</summary>

      <<< @/playground/public/#{locale_key}/zod.ts

      </details>

      <details>
      <summary>OpenAPI</summary>

      <<< @/playground/public/#{locale_key}/openapi.yml

      </details>
    MD
  end

  def file_block(path)
    <<~MD.strip
      <small>`#{path}`</small>

      <<< @/playground/#{path}
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

  def generate_index(examples, temp_examples)
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
      - Generated OpenAPI export
      - Introspection output

      ## Available Examples

      | Example | Description |
      |---------|-------------|
      #{rows.join("\n")}
    MD

    File.write(temp_examples.join('index.md'), content)
  end
end
