# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # ActionDefinition - Schema-specific methods for ActionDefinition
      # This module is prepended when an action's contract has a schema
      module ActionDefinition
        # Override: merges_input? - check if contract has schema
        def merges_input?
          return false unless contract_class.schema?
          return false if resets_input?

          true
        end

        # Override: merges_output? - check if contract has schema
        def merges_output?
          return false unless contract_class.schema?
          return false if resets_output?

          true
        end

        # Override: Define input with auto-wrapping for reset writable actions
        def input(&block)
          # Auto-generate first if needed (before custom block)
          auto_generate_input_if_needed if @reset_input == false && @input_definition.nil?

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

        # Override: Get merged input definition (virtual + explicit)
        def merged_input_definition
          return input_definition unless merges_input?

          # Build virtual input from schema (auto-generated query params for index, etc)
          virtual_def = build_virtual_input_definition
          return input_definition if virtual_def.nil?

          # If no explicit input, return virtual
          return virtual_def if input_definition.nil?

          # Merge: Start with virtual definition, then add/override with explicit params
          merged_def = Definition.new(:input, contract_class)

          # Copy all params from virtual input (auto-generated)
          virtual_def.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          # Override/add with explicit input params
          input_definition.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          merged_def
        end

        # Override: Get merged output definition (virtual + explicit)
        def merged_output_definition
          return output_definition unless merges_output?

          # Build virtual output from schema
          virtual_def = build_virtual_output_definition
          return output_definition if virtual_def.nil?

          # If no explicit output, return virtual
          return virtual_def if output_definition.nil?

          # Merge: Start with virtual definition, then add/override with explicit params
          merged_def = Definition.new(:output, contract_class)

          # Copy all params from virtual output (schema attributes)
          virtual_def.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          # Override/add with explicit output params (like meta)
          output_definition.params.each do |name, param_options|
            merged_def.params[name] = param_options
          end

          merged_def
        end

        # Override: Serialize data via Schema
        def serialize_data(data, context: {}, includes: nil)
          return data unless contract_class.schema?

          needs_serialization = if data.is_a?(Hash)
            false # Already a hash
          elsif data.is_a?(Array)
            data.empty? || data.first.class != Hash
          else
            true # ActiveRecord object/relation
          end

          needs_serialization ? contract_class.schema_class.serialize(data, context: context, includes: includes) : data
        end

        # Schema-dependent: Build virtual input definition from schema class
        def build_virtual_input_definition
          return nil unless contract_class.schema_class

          rc = contract_class.schema_class
          virtual_def = Definition.new(:input, contract_class)

          case action_name.to_sym
          when :index
            virtual_def.instance_eval { Generator.generate_query_params(self, rc) }
          when :show
            # Empty input - strict mode will reject any query params
          when :create
            virtual_def.instance_eval { Generator.generate_writable_input(self, rc, :create) }
          when :update
            virtual_def.instance_eval { Generator.generate_writable_input(self, rc, :update) }
          when :destroy
            # No input by default
          else
            # Custom actions get empty input
            # Input params MUST be defined explicitly in the action block
          end

          virtual_def
        end

        # Schema-dependent: Build virtual output definition from schema class
        def build_virtual_output_definition
          return nil unless contract_class.schema_class

          virtual_def = Definition.new(:output, contract_class)

          # Add all schema attributes
          contract_class.schema_class.attribute_definitions.each do |name, attr_def|
            virtual_def.params[name] = {
              name: name,
              type: Generator.map_type(attr_def.type),
              required: false
            }
          end

          # Add associations
          contract_class.schema_class.association_definitions.each do |name, assoc_def|
            if assoc_def.singular?
              virtual_def.params[name] = { name: name, type: :object, required: false, nullable: assoc_def.nullable? }
            elsif assoc_def.collection?
              virtual_def.params[name] = { name: name, type: :array, required: false, nullable: assoc_def.nullable? }
            end
          end

          virtual_def
        end

        # Schema-dependent: Auto-generate input definition for CRUD and custom actions
        def auto_generate_input_if_needed
          return unless contract_class.schema?



          rc = contract_class.schema_class
          @input_definition = Definition.new(:input, contract_class)

          case action_name.to_sym
          when :index
            @input_definition.instance_eval { Generator.generate_query_params(self, rc) }
          when :show
            # Empty input - strict mode will reject any query params
          when :create
            @input_definition.instance_eval { Generator.generate_writable_input(self, rc, :create) }
          when :update
            @input_definition.instance_eval { Generator.generate_writable_input(self, rc, :update) }
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
            @output_definition.instance_eval { Generator.generate_collection_output(self, rc) }
          when :show, :create, :update
            @output_definition.instance_eval { Generator.generate_single_output(self, rc) }
          when :destroy
            # No output by default
          else
            # Custom actions get single resource output by default (like create/show/update)
            # But respond_with will adapt based on what controller returns (single vs collection)
            @output_definition.instance_eval { Generator.generate_single_output(self, rc) }
          end
        end

        # Schema-dependent: Check if input should be automatically wrapped in root_key
        def should_auto_wrap_input?
          return false unless @reset_input  # Only when reset_input! is used
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
