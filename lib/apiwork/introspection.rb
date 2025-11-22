# frozen_string_literal: true

module Apiwork
  module Introspection
    class << self
      def api(api_class)
        return nil unless api_class.metadata

        resources = {}
        api_class.metadata.resources.each do |resource_name, resource_metadata|
          resources[resource_name] = resource(api_class, resource_name, resource_metadata)
        end

        result = {
          path: api_class.mount_path,
          info: info(api_class.metadata.info),
          types: types(api_class),
          enums: enums(api_class),
          resources: resources
        }

        result[:error_codes] = api_class.metadata.error_codes || []

        result
      end

      def action_definition(action_definition)
        result = {}
        result[:input] = action_definition.merged_input_definition&.as_json
        result[:output] = action_definition.merged_output_definition&.as_json
        result[:error_codes] = all_error_codes(action_definition)
        result
      end

      def contract(contract_class, action: nil)
        if action
          action_definition = contract_class.action_definition(action)
          return nil unless action_definition

          action_definition.as_json
        else
          result = { actions: {} }

          actions = available_actions(contract_class)
          actions = contract_class.action_definitions.keys if actions.empty?

          actions.each do |action_name|
            action_definition = contract_class.action_definition(action_name)
            result[:actions][action_name] = action_definition.as_json if action_definition
          end

          result
        end
      end

      def definition(definition, visited: Set.new)
        return nil unless definition

        return serialize_unwrapped_union(definition, visited: visited) if definition.unwrapped_union?

        result = {}

        definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
          result[name] = serialize_param(name, param_options, definition, visited: visited)
        end

        result
      end

      def serialize_unwrapped_union(definition, visited: Set.new)
        discriminator = definition.instance_variable_get(:@unwrapped_union_discriminator)

        success_params = {}
        issue_params = {}

        definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
          case name
          when :ok
            next # We'll add this manually to each variant
          when :issues
            issue_params[name] = serialize_param(name, param_options, definition, visited: visited).tap do |serialized|
              serialized[:required] = true
            end
          else
            serialized = serialize_param(name, param_options, definition, visited: visited)
            serialized[:required] = true unless name == :meta
            success_params[name] = serialized
          end
        end

        {
          type: :union,
          discriminator: discriminator,
          variants: [
            {
              tag: true,
              type: :object,
              shape: {
                ok: { type: :literal, value: true, required: true },
                **success_params
              }
            },
            {
              tag: false,
              type: :object,
              shape: {
                ok: { type: :literal, value: false, required: true },
                **issue_params
              }
            }
          ]
        }
      end

      def serialize_param(name, options, definition, visited: Set.new)
        if options[:type] == :union
          result = serialize_union(options[:union], definition, visited: visited)
          result[:required] = options[:required] || false
          result[:nullable] = options[:nullable] || false
          apply_metadata_fields(result, options)
          return result
        end

        if options[:custom_type]
          custom_type_name = options[:custom_type]

          custom_type_name = qualified_type_name(custom_type_name, definition) if definition.contract_class.resolve_custom_type(custom_type_name)

          result = {
            type: custom_type_name,
            required: options[:required] || false,
            nullable: options[:nullable] || false
          }
          apply_metadata_fields(result, options)
          result[:as] = options[:as] if options[:as]
          return result
        end

        type_value = options[:type]
        type_value = qualified_type_name(type_value, definition) if type_value && definition.contract_class.resolve_custom_type(type_value)

        result = {
          type: type_value,
          required: options[:required] || false,
          nullable: options[:nullable] || false
        }
        apply_metadata_fields(result, options)

        result[:value] = options[:value] if options[:type] == :literal

        result[:default] = options[:default] if options.key?(:default) && !options[:default].nil?

        if options[:enum]
          if options[:enum].is_a?(Hash) && options[:enum][:ref]
            scope = determine_scope_for_enum(definition, options[:enum][:ref])
            qualified_enum_name = Descriptor.scoped_enum_name(scope, options[:enum][:ref])
            result[:enum] = qualified_enum_name
          else
            result[:enum] = options[:enum]
          end
        end

        result[:as] = options[:as] if options[:as]

        if options[:of]
          result[:of] = if definition.contract_class.resolve_custom_type(options[:of])
                          qualified_type_name(options[:of], definition)
                        else
                          options[:of]
                        end
        end

        result[:shape] = definition(options[:shape], visited: visited) if options[:shape]

        result
      end

      def serialize_union(union_definition, definition, visited: Set.new)
        result = {
          type: :union,
          variants: union_definition.variants.map { |variant| serialize_variant(variant, definition, visited: visited) }
        }
        result[:discriminator] = union_definition.discriminator if union_definition.discriminator
        result
      end

      def serialize_variant(variant_definition, parent_definition, visited: Set.new)
        variant_type = variant_definition[:type]

        custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_type)
        if custom_type_block
          qualified_variant_type = qualified_type_name(variant_type, parent_definition)
          result = { type: qualified_variant_type }
          result[:tag] = variant_definition[:tag] if variant_definition[:tag]
          return result
        end

        result = { type: variant_type }

        result[:tag] = variant_definition[:tag] if variant_definition[:tag]

        if variant_definition[:of]
          result[:of] = if parent_definition.contract_class.resolve_custom_type(variant_definition[:of])
                          qualified_type_name(variant_definition[:of], parent_definition)
                        else
                          variant_definition[:of]
                        end
        end

        if variant_definition[:enum]
          if variant_definition[:enum].is_a?(Symbol)
            if parent_definition.contract_class.respond_to?(:schema_class) &&
               parent_definition.contract_class.schema_class
              scope = determine_scope_for_enum(parent_definition, variant_definition[:enum])
              result[:enum] = Descriptor.scoped_enum_name(scope, variant_definition[:enum])
            else
              result[:enum] = variant_definition[:enum]
            end
          else
            result[:enum] = variant_definition[:enum]
          end
        end

        result[:shape] = definition(variant_definition[:shape], visited: visited) if variant_definition[:shape]

        result
      end

      def scope_for_type(definition)
        definition.contract_class
      end

      def determine_scope_for_enum(definition, enum_name)
        definition.contract_class
      end

      def is_global_type?(type_name, definition)
        return false unless definition.contract_class.respond_to?(:api_class)

        api_class = definition.contract_class.api_class
        return false unless api_class

        type_global?(type_name, api_class: api_class)
      end

      def type_global?(type_name, api_class:)
        store = Descriptor::TypeStore.send(:storage, api_class)
        metadata = store[type_name]
        return false unless metadata

        metadata[:scope].nil?
      end

      def is_imported_type?(type_name, definition)
        return false unless definition.contract_class.respond_to?(:imports)

        import_prefixes = import_prefix_cache(definition.contract_class)

        return true if import_prefixes[:direct].include?(type_name)

        type_name_str = type_name.to_s
        import_prefixes[:prefixes].any? { |prefix| type_name_str.start_with?(prefix) }
      end

      def import_prefix_cache(contract_class)
        @import_prefix_cache ||= {}
        @import_prefix_cache[contract_class] ||= begin
          direct = Set.new(contract_class.imports.keys)
          { direct: direct, prefixes: contract_class.imports.keys.map { |alias_name| "#{alias_name}_" } }
        end
      end

      def qualified_type_name(type_name, definition)
        return type_name if is_global_type?(type_name, definition)
        return type_name if is_imported_type?(type_name, definition)
        return type_name unless definition.contract_class.respond_to?(:schema_class)
        return type_name unless definition.contract_class.schema_class

        scope = scope_for_type(definition)
        Descriptor.scoped_type_name(scope, type_name)
      end

      def apply_metadata_fields(result, options)
        result[:description] = options[:description]
        result[:example] = options[:example]
        result[:format] = options[:format]
        result[:deprecated] = options[:deprecated] || false
        result[:min] = options[:min]
        result[:max] = options[:max]
      end

      # API-level introspection helpers

      def info(metadata_info)
        result = {}

        if metadata_info
          result[:title] = metadata_info[:title]
          result[:version] = metadata_info[:version]
          result[:description] = metadata_info[:description]
        end

        result
      end

      def resource(api_class, resource_name, resource_metadata, parent_path: nil, parent_resource_name: nil)
        resource_path = resource_path_for(api_class, resource_name, resource_metadata, parent_path,
                                          parent_resource_name: parent_resource_name)

        metadata = resource_metadata[:metadata] || {}

        result = {
          path: resource_path,
          summary: metadata[:summary],
          description: metadata[:description],
          tags: metadata[:tags],
          actions: {}
        }

        contract_class = resolve_contract_class(resource_metadata) ||
                         schema_based_contract_class(resource_metadata)

        if resource_metadata[:actions]&.any?
          resource_metadata[:actions].each do |action_name, action_data|
            path = action_path(action_name, action_name.to_sym)
            add_action(result[:actions], action_name, action_data[:method], path, contract_class,
                       metadata: action_data[:metadata])
          end
        end

        if resource_metadata[:members]&.any?
          resource_metadata[:members].each do |action_name, action_metadata|
            path = action_path(action_name, :member)
            add_action(result[:actions], action_name, action_metadata[:method], path, contract_class,
                       metadata: action_metadata[:metadata])
          end
        end

        if resource_metadata[:collections]&.any?
          resource_metadata[:collections].each do |action_name, action_metadata|
            path = action_path(action_name, :collection)
            add_action(result[:actions], action_name, action_metadata[:method], path, contract_class,
                       metadata: action_metadata[:metadata])
          end
        end

        if resource_metadata[:resources]&.any?
          result[:resources] = {}
          resource_metadata[:resources].each do |nested_name, nested_metadata|
            result[:resources][nested_name] = resource(
              api_class,
              nested_name,
              nested_metadata,
              parent_path: resource_path,
              parent_resource_name: resource_name
            )
          end
        end

        result
      end

      def action_path(action_name, action_type)
        case action_type
        when :index, :create
          '/'
        when :show, :update, :destroy
          '/:id'
        when :member
          "/:id/#{action_name}"
        when :collection
          "/#{action_name}"
        else
          '/'
        end
      end

      def add_action(actions, name, method, path, contract_class, metadata: {})
        actions[name] = {
          method: method,
          path: path,
          summary: metadata[:summary],
          description: metadata[:description],
          tags: metadata[:tags],
          deprecated: metadata[:deprecated],
          operation_id: metadata[:operation_id]
        }

        return unless contract_class

        action_definition = contract_class.action_definition(name)
        return unless action_definition

        contract_json = action_definition(action_definition)
        actions[name][:input] = contract_json[:input] || {}
        actions[name][:output] = contract_json[:output] || {}
        actions[name][:error_codes] = contract_json[:error_codes] || []
      end

      def resource_path_for(api_class, resource_name, resource_metadata, parent_path, parent_resource_name: nil)
        resource_segment = if resource_metadata[:singular]
                             resource_name.to_s.singularize
                           else
                             resource_name.to_s
                           end

        if parent_path
          parent_id_param = ":#{parent_resource_name.to_s.singularize}_id"
          "#{parent_id_param}/#{resource_segment}"
        else
          resource_segment
        end
      end

      def all_error_codes(action_definition)
        action_codes = action_definition.instance_variable_get(:@error_codes) || []
        auto_codes = auto_writable_error_codes(action_definition)

        (action_codes + auto_codes).uniq.sort
      end

      def auto_writable_error_codes(action_definition)
        return [] unless action_definition.contract_class.schema?

        action_name_sym = action_definition.action_name.to_sym
        return [422] if [:create, :update].include?(action_name_sym)

        return [] if [:index, :show, :destroy].include?(action_name_sym)

        http_method = find_http_method_from_api_metadata(action_definition)
        return [] unless http_method

        [:post, :patch, :put].include?(http_method) ? [422] : []
      end

      def find_http_method_from_api_metadata(action_definition)
        search_in_api_metadata(action_definition) do |resource_metadata|
          next unless matches_contract?(resource_metadata, action_definition.contract_class)

          action_name_sym = action_definition.action_name.to_sym
          return resource_metadata[:members][action_name_sym][:method] if resource_metadata[:members]&.key?(action_name_sym)

          resource_metadata[:collections][action_name_sym][:method] if resource_metadata[:collections]&.key?(action_name_sym)
        end
      end

      def find_api_for_contract(contract_class)
        Apiwork::API.all.find do |api_class|
          next unless api_class.metadata

          search_in_metadata(api_class.metadata) { |resource| matches_contract?(resource, contract_class) }
        end
      end

      def search_in_api_metadata(action_definition, &block)
        api = find_api_for_contract(action_definition.contract_class)
        return nil unless api&.metadata

        search_in_metadata(api.metadata, &block)
      end

      def search_in_metadata(metadata, &block)
        metadata.search_resources(&block)
      end

      def matches_contract?(resource_metadata, contract_class)
        resource_uses_contract?(resource_metadata, contract_class)
      end

      def resource_uses_contract?(resource_metadata, contract)
        matches_contract_option?(resource_metadata, contract) ||
          matches_schema_contract?(resource_metadata, contract)
      end

      def matches_contract_option?(resource_metadata, contract)
        contract_class = resource_metadata[:contract_class]
        return false unless contract_class

        contract_class == contract
      end

      def matches_schema_contract?(resource_metadata, contract)
        schema_class = resource_metadata[:schema_class]
        return false unless schema_class
        return false unless contract.schema_class

        schema_class == contract.schema_class
      end

      def resolve_contract_class(resource_metadata)
        contract_class = resource_metadata[:contract_class]
        return nil unless contract_class

        contract_class < Contract::Base ? contract_class : nil
      end

      def schema_based_contract_class(resource_metadata)
        schema_class = resource_metadata[:schema_class]
        return nil unless schema_class

        Contract::Base.find_contract_for_schema(schema_class)
      end

      def types(api)
        result = {}

        return result unless api

        type_storage = Descriptor::TypeStore.send(:storage, api)
        type_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          expanded_shape = metadata[:expanded_payload] ||= if metadata[:payload].is_a?(Hash)
                                                             metadata[:payload]
                                                           elsif metadata[:payload].is_a?(Proc)
                                                             expand_type(
                                                               metadata[:payload],
                                                               contract_class: metadata[:scope],
                                                               type_name: metadata[:name]
                                                             )
                                                           else
                                                             expand_type(
                                                               metadata[:definition] || metadata[:payload],
                                                               contract_class: metadata[:scope],
                                                               type_name: metadata[:name]
                                                             )
                                                           end

          result[qualified_name] = if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
                                     expanded_shape.merge(
                                       description: metadata[:description],
                                       example: metadata[:example],
                                       format: metadata[:format],
                                       deprecated: metadata[:deprecated] || false
                                     )
                                   else
                                     {
                                       type: :object,
                                       shape: expanded_shape,
                                       description: metadata[:description],
                                       example: metadata[:example],
                                       format: metadata[:format],
                                       deprecated: metadata[:deprecated] || false
                                     }
                                   end
        end

        result
      end

      def enums(api)
        result = {}

        return result unless api

        enum_storage = Descriptor::EnumStore.send(:storage, api)
        enum_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          enum_data = {
            values: metadata[:payload],
            description: metadata[:description],
            example: metadata[:example],
            deprecated: metadata[:deprecated] || false
          }
          result[qualified_name] = enum_data
        end

        result
      end

      def expand_type(definition, contract_class: nil, type_name: nil)
        temp_contract = contract_class || Class.new(Apiwork::Contract::Base)

        temp_definition = Apiwork::Contract::Definition.new(
          type: :input,
          contract_class: temp_contract
        )

        temp_definition.instance_eval(&definition)
        temp_definition.as_json
      end

      def available_actions(contract_class)
        metadata = resource_metadata(contract_class)
        return [] unless metadata

        actions = metadata[:actions]&.keys || []
        actions += metadata[:members]&.keys || []
        actions += metadata[:collections]&.keys || []
        actions
      end

      def resource_metadata(contract_class)
        api = contract_class.api_class
        return nil unless api&.metadata

        api.metadata.find_resource(resource_name(contract_class))
      end

      def resource_name(contract_class)
        return nil unless contract_class.name

        contract_class.name.demodulize.sub(/Contract$/, '').underscore.pluralize.to_sym
      end
    end
  end
end
