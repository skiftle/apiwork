# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Schema-specific methods for ActionDefinition
      # Prepended when an action's contract has a schema
      module ActionDefinition
        def merges_input?
          return false unless contract_class.schema?
          return false if resets_input?

          true
        end

        def merges_output?
          return false unless contract_class.schema?
          return false if resets_output?

          true
        end

        def input(&block)
          # Auto-generate first if needed (before custom block)
          auto_generate_input_if_needed if merges_input? && @input_definition.nil?

          @input_definition ||= Definition.new(:input, contract_class)

          if block
            if should_auto_wrap_input?
              # Automatically wrap in root_key for reset writable actions
              root_key = contract_class.schema_class.root_key.singular.to_sym
              @input_definition.param root_key, type: :object, required: true do
                instance_eval(&block)
              end
            else
              # Normal behavior: evaluate block directly
              @input_definition.instance_eval(&block)
            end
          end

          @input_definition
        end

        def merged_input_definition
          return input_definition unless merges_input?

          virtual_def = build_virtual_input_definition
          return input_definition if virtual_def.nil?
          return virtual_def if input_definition.nil?

          # Merge virtual (schema-generated) with explicit params
          merged_def = Definition.new(:input, contract_class)

          virtual_def.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          input_definition.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          merged_def
        end

        def merged_output_definition
          return output_definition if output_definition && has_unwrapped_union?
          return output_definition if output_definition && is_destroy_action?
          return output_definition unless merges_output?

          virtual_def = build_virtual_output_definition
          return output_definition if virtual_def.nil?
          return virtual_def if output_definition.nil?

          # Merge virtual (schema-generated) with explicit params
          merged_def = Definition.new(:output, contract_class)

          virtual_def.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          output_definition.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          merged_def
        end

        # Check if this is a destroy action
        def is_destroy_action?
          action_name.to_sym == :destroy
        end

        # Check if output definition has unwrapped union structure
        def has_unwrapped_union?
          return false unless output_definition
          output_definition.params.key?(:ok)
        end

        # Check if this is a CRUD action
        def crud_action?
          %i[index show create update destroy].include?(action_name.to_sym)
        end

        def serialize_data(data, context: {}, includes: nil)
          return data unless contract_class.schema?

          needs_serialization = if data.is_a?(Hash)
                                  false
                                elsif data.is_a?(Array)
                                  data.empty? || data.first.class != Hash
                                else
                                  true
                                end

          needs_serialization ? contract_class.schema_class.serialize(data, context: context, includes: includes) : data
        end

        def build_virtual_input_definition
          return nil unless contract_class.schema_class

          rc = contract_class.schema_class
          virtual_def = Definition.new(:input, contract_class)

          case action_name.to_sym
          when :index
            virtual_def.instance_eval { InputGenerator.generate_query_params(self, rc) }
          when :show
            # Empty input
          when :create
            virtual_def.instance_eval { InputGenerator.generate_writable_input(self, rc, :create) }
          when :update
            virtual_def.instance_eval { InputGenerator.generate_writable_input(self, rc, :update) }
          when :destroy
            # No input
          end

          virtual_def
        end

        def build_virtual_output_definition
          return nil unless contract_class.schema_class

          virtual_def = Definition.new(:output, contract_class)

          contract_class.schema_class.attribute_definitions.each do |name, attribute_definition|
            virtual_def.params[name] = {
              name:,
              type: Generator.map_type(attribute_definition.type),
              required: false
            }
          end

          contract_class.schema_class.association_definitions.each do |name, association_definition|
            if association_definition.singular?
              virtual_def.params[name] = { name:, type: :object, required: false, nullable: association_definition.nullable? }
            elsif association_definition.collection?
              virtual_def.params[name] = { name:, type: :array, required: false, nullable: association_definition.nullable? }
            end
          end

          virtual_def
        end

        def auto_generate_input_if_needed
          return unless contract_class.schema?

          rc = contract_class.schema_class
          @input_definition = Definition.new(:input, contract_class)

          case action_name.to_sym
          when :index
            @input_definition.instance_eval { InputGenerator.generate_query_params(self, rc) }
          when :show
            # Empty input - strict mode will reject any query params
          when :create
            @input_definition.instance_eval { InputGenerator.generate_writable_input(self, rc, :create) }
          when :update
            @input_definition.instance_eval { InputGenerator.generate_writable_input(self, rc, :update) }
          when :destroy
            # No input by default
          else
            # Custom actions get empty input
            # Input params MUST be defined explicitly in the action block
          end
        end

        # Schema-dependent: Auto-generate output definition for CRUD and custom actions
        def auto_generate_output_if_needed
          return unless contract_class.schema?

          rc = contract_class.schema_class
          @output_definition = Definition.new(:output, contract_class)

          case action_name.to_sym
          when :index
            @output_definition.instance_eval { OutputGenerator.generate_collection_output(self, rc) }
          when :show, :create, :update
            @output_definition.instance_eval { OutputGenerator.generate_single_output(self, rc) }
          when :destroy
            # Destroy returns empty response (just 200 OK)
            # Leave @output_definition empty
          else
            # Custom member/collection actions default to single resource output
            # This provides a sensible default that works for most member actions
            # Collection actions can override with reset_output! and explicit output definition
            # The respond_with helper will adapt the response based on what controller returns
            @output_definition.instance_eval { OutputGenerator.generate_single_output(self, rc) }
          end
        end

        # Schema-dependent: Check if input should be automatically wrapped in root_key
        def should_auto_wrap_input?
          return false unless @reset_input # Only when reset_input! is used
          return false unless contract_class.schema?
          return false unless writable_action?

          true
        end

        # Schema-dependent: Check for schema mismatch
        def schema_mismatch?(response, output_def)
          # Check if schema expects single resource but response has collection (plural key)
          resource_key = contract_class.schema_class&.root_key
          return false unless resource_key

          singular_key = resource_key.singular.to_sym
          plural_key = resource_key.plural.to_sym

          # Schema expects singular, response has plural
          if output_def.params.key?(singular_key) && (response.key?(plural_key) || response.key?(plural_key.to_s))
            return true
          end

          # Schema expects plural, response has singular
          if output_def.params.key?(plural_key) && (response.key?(singular_key) || response.key?(singular_key.to_s))
            return true
          end

          false
        end
      end
    end
  end
end
