# frozen_string_literal: true

require 'yard'
require 'fileutils'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'

module Apiwork
  class ReferenceGenerator
    GEM_ROOT = File.expand_path('../..', __dir__)
    OUTPUT_DIR = File.join(GEM_ROOT, 'docs/reference')
    GITHUB_URL = 'https://github.com/skiftle/apiwork/blob/main'
    RUBY_PRIMITIVES = %w[
      String Integer Float Boolean Symbol Hash Array Object
      TrueClass FalseClass NilClass Numeric Proc
    ].to_set.freeze

    class << self
      def generate
        new.generate
      end
    end

    def generate
      parse_source
      modules = extract_modules
      write_files(modules)
    end

    private

    def parse_source
      YARD::Registry.clear
      YARD.parse(File.join(GEM_ROOT, 'lib/**/*.rb'))
    end

    def public_api_yard_objects
      @public_api_yard_objects ||= YARD::Registry.all(:class, :module)
        .select { |yard_object| yard_object.path.start_with?('Apiwork') && public_api?(yard_object) }
    end

    def extract_modules
      public_api_yard_objects
        .map { |yard_object| serialize_module(yard_object) }
        .reject { |mod| mod[:class_methods].empty? && mod[:instance_methods].empty? }
        .sort_by { |mod| mod[:path] }
    end

    def public_api?(yard_object)
      api_tag = yard_object.docstring.tags(:api).find { |tag| tag.text == 'public' }

      if yard_object.type == :method
        return false unless api_tag

        parent = yard_object.namespace
        return true unless parent

        parent_api_tag = parent.docstring.tags(:api).find { |tag| tag.text == 'public' }
        return api_tag.object_id != parent_api_tag&.object_id
      end

      has_own_docstring = !yard_object.docstring.to_s.strip.empty?
      return true if has_own_docstring && api_tag

      return false unless yard_object.file

      lines = File.readlines(yard_object.file)
      docstring_range = yard_object.docstring.line_range

      start_line = if docstring_range
                     docstring_range.first - 1
                   else
                     [yard_object.line - 5, 0].max
                   end
      end_line = yard_object.line

      preceding_lines = lines[start_line...end_line].join
      preceding_lines.include?('@api public')
    end

    def serialize_module(yard_object)
      {
        class_methods: extract_methods(yard_object, :class),
        docstring: yard_object.docstring.to_s,
        examples: extract_examples(yard_object),
        file: relative_path(yard_object.file),
        instance_methods: extract_methods(yard_object, :instance),
        line: yard_object.line,
        name: yard_object.name.to_s,
        path: yard_object.path,
        type: yard_object.type,
      }
    end

    def relative_path(file)
      return nil unless file

      file.delete_prefix("#{GEM_ROOT}/")
    end

    def extract_methods(yard_object, scope)
      methods = yard_object.meths(scope:, visibility: :public)

      yard_object.mixins(:instance).each do |mixin|
        mixin_yard_object = YARD::Registry.at(mixin.path)
        next unless mixin_yard_object

        methods += mixin_yard_object.meths(scope:, visibility: :public)
      end

      methods
        .select { |method| public_api?(method) && documented?(method) }
        .uniq(&:name)
        .sort_by(&:name)
        .map { |method| serialize_method(method) }
    end

    def documented?(method)
      return true unless method.docstring.to_s.strip.empty?

      method.docstring.tags.any? do |tag|
        next false if tag.tag_name == 'api'
        next true if tag.tag_name == 'see' && tag.name.present?
        next true if tag.tag_name == 'return' && tag.types.present?
        next true if tag.tag_name == 'param' && tag.types.present?

        tag.text.to_s.strip.present?
      end
    end

    def serialize_method(method)
      {
        docstring: method.docstring.to_s,
        examples: extract_examples(method),
        file: relative_path(method.file),
        line: method.line,
        name: method.name.to_s,
        params: extract_params(method),
        returns: extract_return(method),
        see: extract_see(method),
        signature: build_signature(method),
        summary: method.docstring.summary,
        yieldparams: extract_yieldparams(method),
      }
    end

    def build_signature(method)
      params = method.parameters.reject { |name, _default| name.to_s.start_with?('internal') }
      params = params.map do |name, default|
        if name.to_s.end_with?(':')
          default ? "#{name} #{default}" : name.to_s
        else
          default ? "#{name} = #{default}" : name.to_s
        end
      end

      name = escape_brackets(method.name.to_s)
      params.any? ? "#{name}(#{params.join(', ')})" : name
    end

    def escape_brackets(text)
      text.gsub('[', '\\[').gsub(']', '\\]')
    end

    def extract_params(method)
      method.docstring.tags(:param).map do |tag|
        parsed = parse_param_description(tag.text)
        {
          default: parsed[:default],
          description: parsed[:description],
          name: tag.name,
          types: tag.types || [],
          values: parsed[:values],
          values_type: parsed[:values_type],
        }
      end
    end

    def format_param_type(param)
      replace_type = param[:values_type] || 'Symbol'

      types = param[:types].map do |t|
        if param[:values]&.any? && t == replace_type
          values = param[:values].join(', ').gsub('|', '\|')
          "`#{t}<#{values}>`"
        else
          "`#{t}`"
        end
      end

      types.join(', ')
    end

    def parse_param_description(text)
      return { default: nil, description: nil, values: nil, values_type: nil } if text.blank?

      match = text.match(/\A(?:\(([^)]+)\))?\s*(?:\[(?:(\w+):\s*)?([^\]]+)\])?\s*(.*)\z/m)
      {
        default: match[1],
        description: match[4].presence,
        values: match[3]&.split(/,\s*/),
        values_type: match[2],
      }
    end

    def extract_return(method)
      tag = method.docstring.tag(:return)
      return nil unless tag

      {
        description: tag.text,
        types: tag.types || [],
      }
    end

    def extract_examples(method)
      method.docstring.tags(:example).map do |tag|
        {
          code: tag.text,
          title: tag.name,
        }
      end
    end

    def extract_see(method)
      method.docstring.tags(:see).map(&:name)
    end

    def extract_yieldparams(method)
      method.docstring.tags(:yieldparam).map do |tag|
        { name: tag.name, types: tag.types || [] }
      end
    end

    def write_files(modules)
      cleanup_old_files
      @modules = modules
      @modules_with_children = build_modules_with_children(modules)

      modules.each.with_index(1) do |mod, order|
        filepath = module_filepath(mod[:path])
        FileUtils.mkdir_p(File.dirname(filepath))
        content = render_module(mod, order)
        File.write(filepath, content)
      end

      write_namespace_indexes
    end

    def write_namespace_indexes
      collect_all_folder_paths.each do |folder_parts|
        folder_path = File.join(OUTPUT_DIR, *folder_parts.map { |p| dasherize(p) })
        index_path = File.join(folder_path, 'index.md')

        next if File.exist?(index_path)

        title = folder_parts.last
        parent_path = "Apiwork::#{folder_parts.join('::')}"
        children = find_direct_children(parent_path)
        first_child = @modules.index { |m| m[:path].start_with?("#{parent_path}::") }
        order = first_child + 1

        content = render_namespace_index(title, parent_path, children, order)
        FileUtils.mkdir_p(folder_path)
        File.write(index_path, content)
      end
    end

    def collect_all_folder_paths
      paths = Set.new

      @modules.each do |mod|
        parts = mod[:path].sub('Apiwork::', '').split('::')

        (1...parts.size).each do |i|
          paths << parts[0...i]
        end

        paths << parts if @modules_with_children.include?(mod[:path])
      end

      paths.to_a.sort_by(&:size)
    end

    def find_direct_children(parent_path)
      @modules
        .select { |m| m[:path].start_with?("#{parent_path}::") }
        .map do |m|
          remaining = m[:path].sub("#{parent_path}::", '')
          remaining.split('::').first
        end
        .uniq
        .sort
    end

    def render_namespace_index(title, parent_path, children, order)
      parts = []
      parts << "---\norder: #{order}\nprev: false\nnext: false\n---\n"
      parts << "# #{title}\n"

      if children.any?
        parts << "## Modules\n"
        render_child_links(parts, parent_path, children)
      end

      parts.join("\n")
    end

    def render_child_links(parts, parent_path, children)
      children.each do |child|
        child_path = dasherize(child)
        child_full_path = "#{parent_path}::#{child}"
        folder = @modules_with_children.include?(child_full_path) ||
                 @modules.none? { |m| m[:path] == child_full_path }
        link = folder ? "./#{child_path}/" : "./#{child_path}"
        parts << "- [#{child}](#{link})"
      end
      parts << ''
    end

    def render_examples(parts, examples)
      examples.each do |example|
        title_suffix = example[:title].blank? ? '' : ": #{example[:title]}"
        parts << "**Example#{title_suffix}**\n"
        parts << '```ruby'
        parts << example[:code]
        parts << "```\n"
      end
    end

    def build_modules_with_children(modules)
      paths = modules.map { |m| m[:path] }.to_set
      paths.select do |path|
        paths.any? { |other| other != path && other.start_with?("#{path}::") }
      end.to_set
    end

    def cleanup_old_files
      Dir.glob(File.join(OUTPUT_DIR, '**/*')).each do |entry|
        next if entry == File.join(OUTPUT_DIR, 'index.md')

        FileUtils.rm_rf(entry)
      end
    end

    def module_filepath(path)
      parts = path.sub('Apiwork::', '').split('::')
      return File.join(OUTPUT_DIR, 'index.md') if parts.empty?

      file_parts = parts.map { |part| dasherize(part) }

      if @modules_with_children.include?(path)
        File.join(OUTPUT_DIR, *file_parts, 'index.md')
      else
        folders = file_parts[0..-2]
        filename = "#{file_parts.last}.md"
        File.join(OUTPUT_DIR, *folders, filename)
      end
    end

    def display_title(path)
      path.sub('Apiwork::', '').split('::').last
    end

    def dasherize(string)
      string.underscore.dasherize
    end

    def linkify_yard_refs(text)
      return text if text.blank?

      result = text.gsub(/\{([^}]+)\}/) do
        ref = ::Regexp.last_match(1)
        link_path = yard_ref_to_path(ref)
        "[#{ref}](#{link_path})"
      end
      escape_html(result)
    end

    def escape_html(text)
      return text if text.blank?

      text.gsub('<', '&lt;').gsub('>', '&gt;')
    end

    def linkify_type(type_str)
      parsed = yard_type_parser.parse(type_str)
      names = extract_type_names(parsed)
      linkable_names = names.select { |name| linkable_type?(name) }

      if linkable_names.empty?
        "`#{type_str}`"
      else
        result = escape_html(type_str)
        linkable_names.each do |name|
          result.gsub!(/\b#{Regexp.escape(name)}\b/, "[#{name}](#{class_to_filepath(name)})")
        end
        result
      end
    rescue StandardError
      "`#{type_str}`"
    end

    def yard_type_parser
      YARD::Tags::TypesExplainer::Parser
    end

    def extract_type_names(types)
      types.flat_map do |type|
        case type
        when YARD::Tags::TypesExplainer::HashCollectionType
          [type.name] + extract_type_names(type.key_types) + extract_type_names(type.value_types)
        when YARD::Tags::TypesExplainer::CollectionType, YARD::Tags::TypesExplainer::FixedCollectionType
          [type.name] + extract_type_names(type.types)
        else
          [type.name]
        end
      end.uniq
    end

    def linkable_type?(type_name)
      return false if RUBY_PRIMITIVES.include?(type_name)

      @linkable_types ||= build_linkable_types
      @linkable_types.include?(type_name)
    end

    def build_linkable_types
      public_api_yard_objects
        .flat_map do |yard_object|
          path = yard_object.path.delete_prefix('Apiwork::')
          parts = path.split('::')
          Array.new(parts.size) { |index| parts[index..].join('::') }
        end
        .reject { |name| RUBY_PRIMITIVES.include?(name) }
        .to_set
    end

    def type_path_lookup
      @type_path_lookup ||= build_type_path_lookup
    end

    def build_type_path_lookup
      lookup = {}
      public_api_yard_objects.each do |yard_object|
        full_path = yard_object.path.delete_prefix('Apiwork::')
        parts = full_path.split('::')

        parts.size.times do |index|
          partial_path = parts[index..].join('::')
          next if RUBY_PRIMITIVES.include?(partial_path)

          lookup[partial_path] ||= full_path
        end
      end

      lookup
    end

    def yard_ref_to_path(ref)
      if ref.start_with?('#', '.')
        "##{ref[1..].dasherize}"
      elsif ref.include?('#')
        class_part, method_part = ref.split('#', 2)
        "#{class_to_filepath(class_part)}##{method_part.dasherize}"
      elsif ref.include?('.')
        class_part, method_part = ref.split('.', 2)
        "#{class_to_filepath(class_part)}##{method_part.dasherize}"
      else
        class_to_filepath(ref)
      end
    end

    def see_ref_linkable?(ref)
      return true if ref.start_with?('#', '.')

      class_part = ref.split(/[#.]/, 2).first
      linkable_type?(class_part)
    end

    def class_to_filepath(class_name)
      resolved = type_path_lookup[class_name] || class_name
      without_apiwork = resolved.delete_prefix('Apiwork::')
      parts = without_apiwork.split('::')

      return '/reference/' if parts.empty?

      file_parts = parts.map { |part| dasherize(part) }
      full_path = "Apiwork::#{without_apiwork}"

      if modules_with_children_for_links.include?(full_path)
        "/reference/#{File.join(*file_parts)}/"
      else
        folders = file_parts[0..-2]
        filename = file_parts.last
        relative_path = folders.any? ? File.join(*folders, filename) : filename
        "/reference/#{relative_path}"
      end
    end

    def modules_with_children_for_links
      @modules_with_children_for_links ||= begin
        paths = type_path_lookup.values.map { |p| "Apiwork::#{p}" }.to_set
        paths.select do |path|
          paths.any? { |other| other != path && other.start_with?("#{path}::") }
        end.to_set
      end
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

      parts << "# #{display_title(mod[:path])}\n"

      if mod[:file] && mod[:line]
        github_link = "#{GITHUB_URL}/#{mod[:file]}#L#{mod[:line]}"
        parts << "[GitHub](#{github_link})\n"
      end

      parts << "#{linkify_yard_refs(mod[:docstring])}\n" if mod[:docstring].present?

      render_examples(parts, mod[:examples]) if mod[:examples].any?

      children = find_direct_children(mod[:path])
      if children.any?
        parts << "## Modules\n"
        render_child_links(parts, mod[:path], children)
      end

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

      parts << "### #{prefix}#{escape_brackets(method[:name])}\n"
      parts << "`#{prefix}#{method[:signature]}`\n"

      if method[:file] && method[:line]
        github_link = "#{GITHUB_URL}/#{method[:file]}#L#{method[:line]}"
        parts << "[GitHub](#{github_link})\n"
      end

      parts << "#{linkify_yard_refs(method[:docstring])}\n" if method[:docstring].present?

      if method[:params].any?
        parts << "**Parameters**\n"

        parts << '<div class="params-table">'
        parts << ''
        parts << '| Name | Type | Default | Description |'
        parts << '|------|------|---------|-------------|'

        method[:params].each do |param|
          name_cell = param[:default] ? "`#{param[:name]}`" : "**`#{param[:name]}`**"
          row = [
            name_cell,
            format_param_type(param),
            param[:default] ? "`#{param[:default]}`" : '',
            linkify_yard_refs(param[:description])&.gsub(/\s*\n\s*/, ' ') || '',
          ]
          parts << "| #{row.join(' | ')} |"
        end
        parts << ''
        parts << '</div>'
        parts << ''
      end

      if method[:returns]
        types = method[:returns][:types].map { |type| linkify_type(type) }.join(', ')
        description = linkify_yard_refs(method[:returns][:description])
        parts << "**Returns**\n"
        parts << (description.blank? ? "#{types}\n" : "#{types} — #{description}\n")
      end

      if method[:yieldparams].any?
        types = method[:yieldparams].flat_map { |p| p[:types] }.uniq
        linked = types.map { |t| linkify_type(t) }.join(', ')
        parts << "**Yields** #{linked}\n"
      end

      if method[:see].any?
        linkable_sees = method[:see].select { |ref| see_ref_linkable?(ref) }
        if linkable_sees.any?
          parts << "**See also**\n"
          linkable_sees.each do |ref|
            link_path = yard_ref_to_path(ref)
            parts << "- [#{ref}](#{link_path})"
          end
          parts << ''
        end
      end

      render_examples(parts, method[:examples]) if method[:examples].any?

      parts << "---\n"
      parts.join("\n")
    end
  end
end
