# frozen_string_literal: true

module Apiwork
  module Contract
    # Represents the contract definition for a single action
    # Handles input/output definitions, merging with resource, and serialization
    class ActionDefinition
      attr_reader :action_name, :contract_class

      def initialize(action_name, contract_class)
        @action_name = action_name
        @contract_class = contract_class
        @reset_input = false
        @reset_output = false
        @input_definition = nil
        @output_definition = nil
      end

      # Reset flags to override virtual contracts
      def reset_input!
        @reset_input = true
      end

      def reset_output!
        @reset_output = true
      end

      def resets_input?
        @reset_input == true
      end

      def resets_output?
        @reset_output == true
      end

      def merges_input?
        contract_class.uses_resource? && !resets_input?
      end

      def merges_output?
        contract_class.uses_resource? && !resets_output?
      end

      # Define input for this action
      # Auto-generates from resource if this is a standard CRUD action (unless reset!)
      def input(&block)
        # Auto-generate first if needed (before custom block)
        auto_generate_input_if_needed unless @reset_input || @input_definition

        @input_definition ||= Definition.new(:input, contract_class)
        @input_definition.instance_eval(&block) if block
        @input_definition
      end

      # Define output for this action
      # Auto-generates from resource if this is a standard CRUD action (unless reset!)
      def output(&block)
        # Auto-generate first if needed (before custom block)
        auto_generate_output_if_needed unless @reset_output || @output_definition

        @output_definition ||= Definition.new(:output, contract_class)
        @output_definition.instance_eval(&block) if block
        @output_definition
      end

      # Get input definition (auto-generates if needed)
      def input_definition
        # Auto-generate if needed and not reset
        auto_generate_input_if_needed unless @reset_input || @input_definition
        @input_definition
      end

      # Get output definition (auto-generates if needed)
      def output_definition
        # Auto-generate if needed and not reset
        auto_generate_output_if_needed unless @reset_output || @output_definition
        @output_definition
      end

      # Get merged input definition (virtual + explicit)
      def merged_input_definition
        return input_definition unless merges_input?
        return input_definition if input_definition.nil?

        # For now, just return explicit input
        # TODO: Implement full merging when needed
        input_definition
      end

      # Get merged output definition (virtual + explicit)
      def merged_output_definition
        return output_definition unless merges_output?

        # Build virtual output from resource
        virtual_def = build_virtual_output_definition
        return output_definition if virtual_def.nil?

        # If no explicit output, return virtual
        return virtual_def if output_definition.nil?

        # Merge: Start with virtual definition, then add/override with explicit params
        merged_def = Definition.new(:output, contract_class)

        # Copy all params from virtual output (resource attributes)
        virtual_def.params.each do |name, param_options|
          merged_def.params[name] = param_options
        end

        # Override/add with explicit output params (like meta)
        output_definition.params.each do |name, param_options|
          merged_def.params[name] = param_options
        end

        merged_def
      end

      # Validate complete response structure (like Zod.parse())
      # Called by Controller after response is fully built
      # @param response [Hash] Complete response with ok, root key, data, meta
      # @return [Hash] Validated response
      # @raise [ValidationError] If output doesn't match definition
      def validate_response(response)
        merged_output = merged_output_definition
        raise ConfigurationError, "No output definition for #{contract_class.name}##{action_name}" unless merged_output

        # Validate complete response structure
        validate_output_data(response, merged_output)

        response
      end

      # Serialize data via Resource (without validation - that happens later)
      # @param data [Object] ActiveRecord object/relation to serialize
      # @param context [Hash] Context for resource serialization
      # @return [Hash, Array] Serialized data (not yet validated)
      def serialize_data(data, context: {})
        return data unless contract_class.uses_resource?

        needs_serialization = if data.is_a?(Hash)
          false # Already a hash
        elsif data.is_a?(Array)
          data.empty? || !data.first.is_a?(Hash)
        else
          true # ActiveRecord object/relation
        end

        needs_serialization ? contract_class.resource_class.serialize(data, context) : data
      end

      private

      # Build virtual output definition from resource class
      def build_virtual_output_definition
        return nil unless contract_class.resource_class

        virtual_def = Definition.new(:output, contract_class)

        # Add all resource attributes
        contract_class.resource_class.attribute_definitions.each do |name, attr_def|
          virtual_def.params[name] = {
            name: name,
            type: Generator.map_type(attr_def.type),
            required: false
          }
        end

        # Add associations
        contract_class.resource_class.association_definitions.each do |name, assoc_def|
          if assoc_def.singular?
            virtual_def.params[name] = { name: name, type: :object, required: false }
          elsif assoc_def.collection?
            virtual_def.params[name] = { name: name, type: :array, required: false }
          end
        end

        virtual_def
      end

      # Validate output data against definition
      # For collections (arrays), validates each item (excluding meta which is response-level)
      # For single objects, validates the object
      def validate_output_data(data, definition)
        if data.is_a?(Array)
          # For collections, validate each item but skip meta validation
          # Meta is added at response level, not per-item
          item_definition_params = definition.params.reject { |k, _v| k == :meta }

          data.each do |item|
            validate_single_output(item, definition, item_definition_params)
          end
        else
          # For single object, validate everything including meta
          validate_single_output(data, definition, definition.params)
        end
      end

      # Validate a single output object against definition
      def validate_single_output(data, definition, params_to_validate = nil)
        return unless data.is_a?(Hash)

        params_to_validate ||= definition.params

        params_to_validate.each do |param_name, param_options|
          value = data[param_name] || data[param_name.to_s]

          # Check required fields
          if param_options[:required] && value.nil?
            raise ValidationError.new(
              code: :missing_field,
              detail: "Required field '#{param_name}' is missing in output"
            )
          end

          # Validate nested objects if present
          if value && param_options[:nested] && value.is_a?(Hash)
            validate_single_output(value, param_options[:nested], param_options[:nested].params)
          end

          # Validate arrays of nested objects
          if value && param_options[:type] == :array && param_options[:nested] && value.is_a?(Array)
            value.each do |item|
              validate_single_output(item, param_options[:nested], param_options[:nested].params) if item.is_a?(Hash)
            end
          end
        end
      end

      # Auto-generate input definition for CRUD and custom actions
      # Custom actions get empty input by default (strict mode, no params allowed)
      def auto_generate_input_if_needed
        return unless contract_class.uses_resource?

        require_relative 'generator' unless defined?(Apiwork::Contract::Generator)

        rc = contract_class.resource_class
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
          # Custom actions get empty input (strict mode, no query params)
          # If you need input, define it explicitly in the action block
        end
      end

      # Auto-generate output definition for CRUD and custom actions
      # Custom actions get single resource output by default (like update)
      def auto_generate_output_if_needed
        return unless contract_class.uses_resource?

        require_relative 'generator' unless defined?(Apiwork::Contract::Generator)

        rc = contract_class.resource_class
        @output_definition = Definition.new(:output, contract_class)

        case action_name.to_sym
        when :index
          @output_definition.instance_eval { Generator.generate_collection_output(self, rc) }
        when :show, :create, :update
          @output_definition.instance_eval { Generator.generate_single_output(self, rc) }
        when :destroy
          # No output by default
        else
          # Custom actions get single resource output (like update/show)
          @output_definition.instance_eval { Generator.generate_single_output(self, rc) }
        end
      end

      # Check if this is a standard CRUD action
      def standard_crud_action?
        %i[index show create update destroy].include?(action_name.to_sym)
      end
    end
  end
end
