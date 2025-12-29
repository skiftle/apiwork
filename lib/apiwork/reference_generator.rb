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
      YARD.parse(File.join(GEM_ROOT, 'lib/**/*.rb'))
    end

    def extract_modules
      YARD::Registry.all(:class, :module)
                    .select { |obj| obj.path.start_with?('Apiwork') }
                    .select { |obj| public_api?(obj) }
                    .map { |obj| serialize_module(obj) }
                    .reject { |mod| mod[:class_methods].empty? && mod[:instance_methods].empty? }
                    .sort_by { |mod| mod[:path] }
    end

    def public_api?(obj)
      api_tag = obj.docstring.tags(:api).find { |t| t.text == 'public' }

      if obj.type == :method
        # For methods, check if @api tag is inherited from parent class/module
        # by comparing object_id with parent's tag
        return false unless api_tag

        parent = obj.namespace
        return true unless parent

        parent_api_tag = parent.docstring.tags(:api).find { |t| t.text == 'public' }
        return api_tag.object_id != parent_api_tag&.object_id
      end

      # For classes/modules with own docstring and @api tag
      has_own_docstring = !obj.docstring.to_s.strip.empty?
      return true if has_own_docstring && api_tag

      # Fallback: check file for @api public in class/module comment
      return false unless obj.file

      lines = File.readlines(obj.file)
      docstring_range = obj.docstring.line_range

      start_line = if docstring_range
                     docstring_range.first - 1
                   else
                     [obj.line - 5, 0].max
                   end
      end_line = obj.line

      preceding_lines = lines[start_line...end_line].join
      preceding_lines.include?('@api public')
    end

    def serialize_module(obj)
      {
        name: obj.name.to_s,
        path: obj.path,
        type: obj.type,
        docstring: obj.docstring.to_s,
        examples: extract_examples(obj),
        file: relative_path(obj.file),
        line: obj.line,
        class_methods: extract_methods(obj, :class),
        instance_methods: extract_methods(obj, :instance)
      }
    end

    def relative_path(file)
      return nil unless file

      file.delete_prefix("#{GEM_ROOT}/")
    end

    def extract_methods(obj, scope)
      methods = obj.meths(visibility: :public, scope:)

      # Include methods from included modules (concerns)
      # Concerns are included at instance scope but may define class methods
      # via @!scope class, so we check instance mixins for both scopes
      obj.mixins(:instance).each do |mixin|
        mixin_obj = YARD::Registry.at(mixin.path)
        next unless mixin_obj

        methods += mixin_obj.meths(visibility: :public, scope:)
      end

      methods
        .select { |m| public_api?(m) }
        .select { |m| documented?(m) }
        .uniq(&:name)
        .sort_by(&:name)
        .map { |m| serialize_method(m) }
    end

    def documented?(method)
      return true unless method.docstring.to_s.strip.empty?

      useful_tags = method.docstring.tags.reject do |t|
        t.tag_name == 'api' || t.text.to_s.strip.empty?
      end
      useful_tags.any?
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
        file: relative_path(method.file),
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
      cleanup_old_files

      order = 1
      modules.each do |mod|
        filepath = module_filepath(mod[:path])
        FileUtils.mkdir_p(File.dirname(filepath))
        content = render_module(mod, order)
        File.write(filepath, content)
        order += 1
      end
    end

    def cleanup_old_files
      Dir.glob(File.join(OUTPUT_DIR, '**/*')).each do |entry|
        next if entry.end_with?('/index.md') || entry == File.join(OUTPUT_DIR, 'index.md')

        FileUtils.rm_rf(entry)
      end
    end

    def module_filepath(path)
      parts = path.sub('Apiwork::', '').split('::')
      file_parts = parts.map { |p| dasherize(p) }
      filename = file_parts.any? ? "#{file_parts.join('-')}.md" : 'index.md'
      File.join(OUTPUT_DIR, filename)
    end

    def display_title(path)
      path.sub('Apiwork::', '')
    end

    def dasherize(str)
      str.underscore.dasherize
    end

    def linkify_yard_refs(text)
      return text if text.blank?

      text.gsub(/\{([^}]+)\}/) do
        ref = ::Regexp.last_match(1)
        link_path = yard_ref_to_path(ref)
        "[#{ref}](#{link_path})"
      end
    end

    def linkify_type(type_str)
      parts = type_str.split(/,\s*/)
      linked_parts = parts.map do |part|
        if linkable_type?(part)
          "[#{part}](#{class_to_filepath(part)})"
        else
          "`#{part}`"
        end
      end
      linked_parts.join(', ')
    end

    def linkable_type?(type_name)
      @linkable_types ||= build_linkable_types
      @linkable_types.include?(type_name)
    end

    def build_linkable_types
      YARD::Registry.all(:class, :module)
                    .select { |obj| obj.path.start_with?('Apiwork') }
                    .select { |obj| public_api?(obj) }
                    .flat_map { |obj| [obj.name.to_s, obj.path.delete_prefix('Apiwork::')] }
                    .to_set
    end

    def yard_ref_to_path(ref)
      # Handle method refs: "ActionDefinition#request" → "contract-action-definition.md#requestreplace-false-block"
      if ref.include?('#')
        class_part, method_part = ref.split('#', 2)
        file_path = class_to_filepath(class_part)
        "#{file_path}##{method_part.dasherize}"
      elsif ref.include?('.')
        # Class method: "Adapter.register" → "adapter.md#register"
        class_part, method_part = ref.split('.', 2)
        file_path = class_to_filepath(class_part)
        "#{file_path}##{method_part.dasherize}"
      else
        class_to_filepath(ref)
      end
    end

    def class_to_filepath(class_name)
      # "Adapter::ContractRegistrar" → "adapter-contract-registrar"
      # "Contract::RequestDefinition" → "contract-request-definition"
      # "ActionDefinition" → "contract-action-definition"
      without_apiwork = class_name.delete_prefix('Apiwork::')

      # If it was under Contract::, keep that as a prefix
      if without_apiwork.start_with?('Contract::')
        normalized = without_apiwork.delete_prefix('Contract::')
        "contract-#{dasherize(normalized)}"
      elsif contract_class?(class_name)
        # Short name like "ActionDefinition" that belongs to Contract
        "contract-#{dasherize(without_apiwork)}"
      else
        dasherize(without_apiwork.gsub('::', '-'))
      end
    end

    def contract_class?(class_name)
      @contract_classes ||= build_contract_classes
      @contract_classes.include?(class_name)
    end

    def build_contract_classes
      YARD::Registry.all(:class, :module)
                    .select { |obj| obj.path.start_with?('Apiwork::Contract::') }
                    .map { |obj| obj.name.to_s }
                    .to_set
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

      if mod[:examples].any?
        mod[:examples].each do |example|
          title_suffix = example[:title].blank? ? '' : ": #{example[:title]}"
          parts << "**Example#{title_suffix}**\n"
          parts << '```ruby'
          parts << example[:code]
          parts << "```\n"
        end
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
        parts << '| Name | Type | Description |'
        parts << '|------|------|-------------|'
        method[:params].each do |param|
          types = param[:types].join(', ')
          desc = linkify_yard_refs(param[:description])
          parts << "| `#{param[:name]}` | `#{types}` | #{desc} |"
        end
        parts << ''
      end

      if method[:returns]
        types = method[:returns][:types].map { |t| linkify_type(t) }.join(', ')
        parts << "**Returns**\n"
        parts << "#{types} — #{linkify_yard_refs(method[:returns][:description])}\n"
      end

      if method[:examples].any?
        method[:examples].each do |example|
          title_suffix = example[:title].blank? ? '' : ": #{example[:title]}"
          parts << "**Example#{title_suffix}**\n"
          parts << '```ruby'
          parts << example[:code]
          parts << "```\n"
        end
      end

      parts << "---\n"
      parts.join("\n")
    end
  end
end
