# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
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
          auto_generate_input_if_needed

          @reset_input = replace if replace

          @input_definition ||= Definition.new(
            type: :input,
            contract_class: contract_class,
            action_name: action_name
          )

          if block
            if should_auto_wrap_input?
              root_key = contract_class.schema_class.root_key.singular.to_sym
              @input_definition.param root_key, type: :object, required: true do
                instance_eval(&block)
              end
            else
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

          virtual_def.params.each do |name, param_options|
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

          if virtual_def.instance_variable_get(:@unwrapped_union)
            output_definition.instance_variable_set(:@unwrapped_union, true)
            output_definition.instance_variable_set(
              :@unwrapped_union_discriminator,
              virtual_def.instance_variable_get(:@unwrapped_union_discriminator)
            )
          end

          virtual_def.params.each do |name, param_options|
            if name == :ok
              output_definition.params[name] = param_options
            else
              output_definition.params[name] = param_options unless output_definition.params.key?(name)
            end
          end

          output_definition
        end

        def is_destroy_action?
          action_name.to_sym == :destroy
        end

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
            add_include_param_if_needed(virtual_def, schema_class)
          when :create
            virtual_def.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :create) }
            add_include_param_if_needed(virtual_def, schema_class)
          when :update
            virtual_def.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :update) }
            add_include_param_if_needed(virtual_def, schema_class)
          when :destroy
            # Destroy actions intentionally have no input params beyond standard routing params
          else
            add_include_param_if_needed(virtual_def, schema_class) if member_action?
          end

          virtual_def
        end

        def add_include_param_if_needed(virtual_def, schema_class)
          return unless schema_class.association_definitions.any?

          include_type = TypeBuilder.build_include_type(contract_class, schema_class)
          virtual_def.param :include, type: include_type, required: false
        end

        def build_virtual_output_definition
          schema_class = contract_class.schema_class
          virtual_def = Definition.new(
            type: :output,
            contract_class: contract_class,
            action_name: action_name
          )

          case action_name.to_sym
          when :index
            virtual_def.instance_eval { OutputGenerator.generate_collection_output(self, schema_class) }
          when :show, :create, :update
            virtual_def.instance_eval { OutputGenerator.generate_single_output(self, schema_class) }
          when :destroy
            # Destroy actions return no output body by convention (HTTP 204)
          else
            return nil unless output_definition

            if collection_action?
              virtual_def.instance_eval { OutputGenerator.generate_collection_output(self, schema_class) }
            else
              virtual_def.instance_eval { OutputGenerator.generate_single_output(self, schema_class) }
            end
          end

          virtual_def
        end

        def collection_action?
          return true if action_name.to_sym == :index

          api = find_api_for_contract
          return false unless api&.metadata

          api.metadata.search_resources do |resource_metadata|
            next unless resource_uses_contract?(resource_metadata, contract_class)

            true if resource_metadata[:collections]&.key?(action_name.to_sym)
          end || false
        end

        def member_action?
          return true if %i[show create update].include?(action_name.to_sym)

          api = find_api_for_contract
          return false unless api&.metadata

          api.metadata.search_resources do |resource_metadata|
            next unless resource_uses_contract?(resource_metadata, contract_class)

            true if resource_metadata[:members]&.key?(action_name.to_sym)
          end || false
        end

        def find_api_for_contract
          Apiwork::API.all.find do |api_class|
            next unless api_class.metadata

            api_class.metadata.search_resources { |resource| resource_uses_contract?(resource, contract_class) }
          end
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
            # Show actions only need route params, include params added via merge if associations exist
          when :create
            @input_definition.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :create) }
          when :update
            @input_definition.instance_eval { InputGenerator.generate_writable_input(self, schema_class, :update) }
          when :destroy
            # Destroy actions have no input params beyond route params
          else
            # Custom actions don't auto-generate input
          end
        end

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
            # Destroy actions return no output body by convention
          else
            # Custom actions don't auto-generate output
          end
        end

        def should_auto_wrap_input?
          return false unless @reset_input # Only when reset_input! is used
          return false unless %i[create update].include?(action_name.to_sym)

          true
        end
      end
    end
  end
end
