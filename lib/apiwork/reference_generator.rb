# frozen_string_literal: true

require 'set'
require 'yard'
require 'fileutils'
require 'active_support/core_ext/string/inflections'

module Apiwork
  class ReferenceGenerator
    OUTPUT_DIR = File.expand_path('../../docs/reference', __dir__)
    GITHUB_URL = 'https://github.com/skiftle/apiwork/blob/main'

    def self.run
      new.generate
    end

    def generate
      parse_source
      modules = extract_modules
      write_files(modules)
    end

    private

    def parse_source
      YARD::Registry.clear
      YARD.parse('lib/**/*.rb')
    end

    def extract_modules
      YARD::Registry.all(:class, :module)
        .select { |obj| obj.path.start_with?('Apiwork::') }
        .reject { |obj| obj.path.include?('Private') }
        .sort_by(&:path)
        .map { |obj| serialize_module(obj) }
    end

    def serialize_module(obj)
      {
        name: obj.name.to_s,
        path: obj.path,
        type: obj.type,
        docstring: obj.docstring.to_s,
        file: obj.file,
        line: obj.line,
        class_methods: extract_methods(obj, :class),
        instance_methods: extract_methods(obj, :instance)
      }
    end

    def extract_methods(obj, scope)
      obj.meths(visibility: :public, scope:)
        .reject { |m| m.name.to_s.start_with?('_') }
        .sort_by(&:name)
        .map { |m| serialize_method(m) }
    end

    def serialize_method(method)
      {
        name: method.name.to_s,
        signature: build_signature(method),
        docstring: method.docstring.to_s,
        summary: method.docstring.summary,
        params: extract_params(method),
        returns: extract_return(method),
        examples: extract_examples(method),
        file: method.file,
        line: method.line
      }
    end

    def build_signature(method)
      params = method.parameters.map do |name, default|
        default ? "#{name} = #{default}" : name.to_s
      end
      name = escape_brackets(method.name.to_s)
      "#{name}(#{params.join(', ')})"
    end

    def escape_brackets(text)
      text.gsub('[', '\\[').gsub(']', '\\]')
    end

    def extract_params(method)
      method.docstring.tags(:param).map do |tag|
        {
          name: tag.name,
          types: tag.types || [],
          description: tag.text
        }
      end
    end

    def extract_return(method)
      tag = method.docstring.tag(:return)
      return nil unless tag

      {
        types: tag.types || [],
        description: tag.text
      }
    end

    def extract_examples(method)
      method.docstring.tags(:example).map do |tag|
        {
          title: tag.name,
          code: tag.text
        }
      end
    end

    def write_files(modules)
      # Rensa gamla mappar (alla utom index.md)
      cleanup_old_directories

      # Bygg en set av alla paths som har children
      all_paths = modules.map { |m| m[:path] }
      parents = find_parent_paths(all_paths)

      order = 1
      modules.each do |mod|
        filepath = module_filepath(mod[:path], parents)
        FileUtils.mkdir_p(File.dirname(filepath))
        content = render_module(mod, order)
        File.write(filepath, content)
        order += 1
      end
    end

    def cleanup_old_directories
      Dir.glob(File.join(OUTPUT_DIR, '*')).each do |entry|
        next if entry.end_with?('index.md')

        FileUtils.rm_rf(entry) if File.directory?(entry)
      end
    end

    def find_parent_paths(all_paths)
      parents = Set.new
      all_paths.each do |path|
        parts = path.split('::')
        # Varje prefix som har children är en parent
        (1...parts.size).each do |i|
          prefix = parts[0...i].join('::')
          parents.add(prefix) if all_paths.any? { |p| p != prefix && p.start_with?("#{prefix}::") }
        end
      end
      parents
    end

    def module_filepath(path, parents)
      # Ta bort Apiwork:: prefix
      parts = path.sub('Apiwork::', '').split('::')

      # Om denna modul är en parent, blir den index.md i sin egen mapp
      if parents.include?(path)
        dir = File.join(OUTPUT_DIR, *parts.map { |p| dasherize(p) })
        return File.join(dir, 'index.md')
      end

      # Annars: hitta närmaste parent och placera filen där
      dir_parts = []
      file_parts = []

      parts.each_with_index do |part, idx|
        prefix = (['Apiwork'] + parts[0..idx]).join('::')
        if parents.include?(prefix)
          dir_parts << dasherize(part)
        else
          file_parts << dasherize(part)
        end
      end

      dir = File.join(OUTPUT_DIR, *dir_parts)
      filename = file_parts.any? ? "#{file_parts.join('-')}.md" : 'index.md'
      File.join(dir, filename)
    end

    def short_title(path)
      path.split('::').last
    end

    def dasherize(str)
      str.underscore.dasherize
    end

    def render_module(mod, order)
      parts = []

      parts << <<~FRONTMATTER
        ---
        order: #{order}
        prev: false
        next: false
        ---
      FRONTMATTER

      parts << "# #{short_title(mod[:path])}\n"

      if mod[:file] && mod[:line]
        github_link = "#{GITHUB_URL}/#{mod[:file]}#L#{mod[:line]}"
        parts << "[GitHub](#{github_link})\n"
      end

      parts << "#{mod[:docstring]}\n" unless mod[:docstring].to_s.empty?

      if mod[:class_methods].any?
        parts << "## Class Methods\n"
        mod[:class_methods].each do |method|
          parts << render_method(method, '.')
        end
      end

      if mod[:instance_methods].any?
        parts << "## Instance Methods\n"
        mod[:instance_methods].each do |method|
          parts << render_method(method, '#')
        end
      end

      parts.join("\n")
    end

    def render_method(method, prefix)
      parts = []

      parts << "### #{prefix}#{method[:signature]}\n"

      if method[:file] && method[:line]
        github_link = "#{GITHUB_URL}/#{method[:file]}#L#{method[:line]}"
        parts << "[GitHub](#{github_link})\n"
      end

      parts << "#{method[:docstring]}\n" unless method[:docstring].to_s.empty?

      if method[:params].any?
        parts << "**Parameters**\n"
        parts << "| Name | Type | Description |"
        parts << "|------|------|-------------|"
        method[:params].each do |param|
          types = param[:types].join(', ')
          parts << "| `#{param[:name]}` | `#{types}` | #{param[:description]} |"
        end
        parts << ""
      end

      if method[:returns]
        types = method[:returns][:types].join(', ')
        parts << "**Returns**\n"
        parts << "`#{types}` — #{method[:returns][:description]}\n"
      end

      if method[:examples].any?
        method[:examples].each do |example|
          title_suffix = example[:title].to_s.empty? ? '' : ": #{example[:title]}"
          parts << "**Example#{title_suffix}**\n"
          parts << "```ruby"
          parts << example[:code]
          parts << "```\n"
        end
      end

      parts << "---\n"
      parts.join("\n")
    end
  end
end
