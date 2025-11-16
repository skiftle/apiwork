# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Schema-specific methods for ActionDefinition
      # Prepended when an action's contract has a schema
      module ActionDefinition
        def merges_input?
          return false if resets_input?

          true
        end

        def merges_output?
          return false if resets_output?

          true
        end

        def input(replace: false, &block)
          # Auto-generate first if needed (before custom block)
          auto_generate_input_if_needed

          # Set reset flag if replace is true
          @reset_input = replace if replace

          @input_definition ||= Definition.new(
            type: :input,
            contract_class: contract_class,
            action_name: action_name
          )

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

          # Merge by adding virtual params to the existing input_definition
          # This preserves enum/type registrations that are keyed by the Definition instance
          virtual_def.params.each do |name, param_options|
            # Only add if not already defined (explicit params override virtual ones)
            input_definition.params[name] ||= param_options
          end

          input_definition
        end

        def merged_output_definition
          return output_definition if output_definition && has_unwrapped_union?
          return output_definition if output_definition && is_destroy_action?
          return output_definition unless merges_output?

          virtual_def = build_virtual_output_definition
          return output_definition if virtual_def.nil?
          return virtual_def if output_definition.nil?

          # Copy unwrapped union metadata from virtual to output_definition if present
          # This ensures the merged output is still recognized as a discriminated union
          if virtual_def.instance_variable_get(:@unwrapped_union)
            output_definition.instance_variable_set(:@unwrapped_union, true)
            output_definition.instance_variable_set(
              :@unwrapped_union_discriminator,
              virtual_def.instance_variable_get(:@unwrapped_union_discriminator)
            )
          end

          # Merge by adding virtual params to the existing output_definition
          # This preserves enum/type registrations that are keyed by the Definition instance
          virtual_def.params.each do |name, param_options|
            # ok parameter cannot be overridden - always use virtual definition
            # Required for discriminated union pattern used by type generators
            if name == :ok
              output_definition.params[name] = param_options
            else
              # Virtual params are added first, custom params override them
              output_definition.params[name] = param_options unless output_definition.params.key?(name)
            end
          end

          # NOTE: We modify output_definition in-place to preserve enum/type registrations
          output_definition
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

        def serialize_data(data, context: {}, includes: nil)
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
          schema_class = contract_class.schema_class
          virtual_def = Definition.new(
            type: :input,
            contract_class: contract_class,
            action_name: action_name
          )

          case action_name.to_sym
          when :index
            virtual_def.instance_eval { InputGenerator.generate_query_params(self, schema_class) }
          when :show
            # Empty input
          when :create
            virtual_def.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :create) }
          when :update
            virtual_def.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :update) }
          when :destroy
            # No input
          end

          virtual_def
        end

        def build_virtual_output_definition
          schema_class = contract_class.schema_class
          virtual_def = Definition.new(
            type: :output,
            contract_class: contract_class,
            action_name: action_name
          )

          # Generate output based on action type
          case action_name.to_sym
          when :index
            virtual_def.instance_eval { OutputGenerator.generate_collection_output(self, schema_class) }
          when :show, :create, :update
            virtual_def.instance_eval { OutputGenerator.generate_single_output(self, schema_class) }
          when :destroy
            # Destroy has empty output
          else
            # Custom actions: only generate wrapper if there's an explicit output definition
            return nil unless output_definition

            # Generate wrapper based on whether it's a collection or member action
            if collection_action?
              virtual_def.instance_eval { OutputGenerator.generate_collection_output(self, schema_class) }
            else
              virtual_def.instance_eval { OutputGenerator.generate_single_output(self, schema_class) }
            end
          end

          virtual_def
        end

        # Check if this action is a collection action (returns array of resources)
        # CRUD action :index is always collection
        # Custom actions are checked from API metadata (collection do ... end)
        def collection_action?
          return true if action_name.to_sym == :index

          # For custom actions, check API metadata
          api = find_api_for_contract
          return false unless api&.metadata

          # Check if action is defined under collection in any resource using this contract
          api.metadata.search_resources do |resource_metadata|
            next unless resource_uses_contract?(resource_metadata, contract_class)

            true if resource_metadata[:collections]&.key?(action_name.to_sym)
          end || false
        end

        def auto_generate_input_if_needed
          return if @input_definition # Make idempotent

          schema_class = contract_class.schema_class
          @input_definition = Definition.new(
            type: :input,
            contract_class: contract_class,
            action_name: action_name
          )

          case action_name.to_sym
          when :index
            @input_definition.instance_eval { InputGenerator.generate_query_params(self, schema_class) }
          when :show
            # Empty input - strict mode will reject any query params
          when :create
            @input_definition.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :create) }
          when :update
            @input_definition.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :update) }
          when :destroy
            # No input by default
          else
            # Custom actions get empty input
            # Input params MUST be defined explicitly in the action block
          end
        end

        # Schema-dependent: Auto-generate output definition for CRUD and custom actions
        def auto_generate_output_if_needed
          schema_class = contract_class.schema_class
          @output_definition = Definition.new(
            type: :output,
            contract_class: contract_class,
            action_name: action_name
          )

          case action_name.to_sym
          when :index
            @output_definition.instance_eval { OutputGenerator.generate_collection_output(self, schema_class) }
          when :show, :create, :update
            @output_definition.instance_eval { OutputGenerator.generate_single_output(self, schema_class) }
          when :destroy
            # Destroy returns empty response (just 200 OK)
            # Leave @output_definition empty
          else
            # Custom actions must define their own output
            # Leave @output_definition empty
          end
        end

        # Schema-dependent: Check if input should be automatically wrapped in root_key
        def should_auto_wrap_input?
          return false unless @reset_input # Only when reset_input! is used
          return false unless %i[create update].include?(action_name.to_sym)

          true
        end
      end
    end
  end
end
