# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'
require_relative '../transform/case'
require_relative 'action_definition'

module Apiwork
  module Contract
    class Base
      class << self
        attr_accessor :_schema_class

        def inherited(subclass)
          super
          # Initialize action definitions hash for each subclass
          subclass.instance_variable_set(:@action_definitions, {})
          # Initialize custom types hash for each subclass
          subclass.instance_variable_set(:@custom_types, {})
        end

        # DSL method for explicit schema declaration
        # Accepts String for lazy loading (preferred per guidelines)
        def schema(ref = nil)
          if ref
            # Setting schema - store reference
            @_schema_class = ref
          else
            # Getting schema
            @_schema_class
          end
        end

        # Get schema class (resolves string references)
        def schema_class
          return nil unless @_schema_class

          resolve_schema_ref(@_schema_class)
        end

        # Check if this contract uses a schema
        def schema?
          !@_schema_class.nil?
        end

        # DSL method to define a custom type
        # @param name [Symbol] Name of the custom type
        # @param block [Proc] Block defining the type's parameters
        def type(name, &block)
          @custom_types ||= {}
          raise ArgumentError, "Custom type #{name} already defined" if @custom_types.key?(name)
          raise ArgumentError, "Block required for custom type definition" unless block_given?

          @custom_types[name] = block
        end

        # Get custom types hash
        # @return [Hash] Hash of custom type names to blocks
        def custom_types
          @custom_types || {}
        end

        # DSL method to define an action
        # @param action_name [Symbol] Name of the action (:index, :show, :create, etc.)
        # @param block [Proc] Block to configure the action (merges with auto-generated if standard CRUD)
        def action(action_name, &block)
          @action_definitions ||= {}
          action_sym = action_name.to_sym

          # Create action definition
          action_def = ActionDefinition.new(action_sym, self)

          # Apply custom block - auto-generation happens lazily in input/output methods
          action_def.instance_eval(&block) if block_given?

          @action_definitions[action_sym] = action_def
        end

        # Get ActionDefinition for a specific action
        # Auto-generates actions if not explicitly defined and we have a resource
        # @param action_name [Symbol] Name of the action
        # @return [ActionDefinition, nil] The action definition or nil if not found
        def action_definition(action_name)
          @action_definitions ||= {}
          action_sym = action_name.to_sym

          # Return existing definition if present
          return @action_definitions[action_sym] if @action_definitions.key?(action_sym)

          # Auto-generate action if we have a schema (for any action, not just CRUD)
          if schema_class
            auto_generate_and_store_action(action_sym)
            return @action_definitions[action_sym]
          end

          nil
        end

        # Get all action definitions
        # @return [Hash] Hash of action names to ActionDefinition objects
        def action_definitions
          @action_definitions || {}
        end

        private

        # Auto-generate and store a standard CRUD action (lazy loading)
        def auto_generate_and_store_action(action_name)
          require_relative 'generator' unless defined?(Generator)
          action_def = Generator.generate_action(schema_class, action_name)
          @action_definitions[action_name.to_sym] = action_def if action_def
        end

        # Resolve schema reference (Class, String, or Symbol)
        def resolve_schema_ref(ref)
          case ref
          when nil then nil
          when Class then ref
          when String then ref.constantize
          when Symbol then ref.to_s.camelize.constantize
          else
            raise ArgumentError, "schema must be a Class, String, Symbol, or nil, got #{ref.class}"
          end
        end
      end

      # Instance methods for validation (used by Controller::Validation)

      def validate_input(action_name, request, options = {})
        params = parse_request_params(request)

        action_def = self.class.action_definition(action_name)
        return { params: params, errors: [] } unless action_def

        action_def.input_definition&.validate(params, options) || { params: params, errors: [] }
      end

      def validate_output(action_name, data, options = {})
        action_def = self.class.action_definition(action_name)
        return { params: data, errors: [] } unless action_def

        action_def.output_definition&.validate(data, options) || { params: data, errors: [] }
      end

      private

      def parse_request_params(request)
        query = parse_query_params(request)
        body = parse_body_params(request)
        query.merge(body)
      end

      def parse_query_params(request)
        return {} unless request.query_parameters

        params = request.query_parameters
        params = Transform::Case.hash(params, key_transform)
        params = params.deep_symbolize_keys

        # Normalize hash with numeric keys to array (for filter/sort/include params)
        # Handles URL params like: filter[0][...]=...&filter[1][...]=...
        normalize_indexed_hashes(params)
      end

      def parse_body_params(request)
        return {} unless request.post? || request.patch? || request.put?

        body_hash = request.request_parameters.except(:controller, :action, :format)
        body_hash = Transform::Case.hash(body_hash, key_transform)
        body_hash.deep_symbolize_keys
      end

      def key_transform
        Apiwork.configuration.deserialize_key_transform
      end

      # Recursively normalize hashes with numeric string keys to arrays
      # Handles URL params like: filter[0][...]=...&filter[1][...]=...
      # Which Rails parses as: {filter: {"0"=>{...}, "1"=>{...}}}
      # Converts to: {filter: [{...}, {...}]}
      #
      # NOTE: Only normalizes VALUES, never the top-level params hash itself
      # to ensure we always return a Hash that can be merged
      def normalize_indexed_hashes(params)
        return params unless params.is_a?(Hash)

        # Normalize values only, preserve top-level hash structure
        params.transform_values do |value|
          normalize_indexed_value(value)
        end
      end

      def normalize_indexed_value(value)
        case value
        when Hash
          # Check if this hash has all numeric keys (indicates indexed array from URL)
          if value.keys.all? { |k| k.to_s.match?(/^\d+$/) }
            # Sort by numeric key and extract values to create array
            value.sort_by { |k, _| k.to_s.to_i }.map { |_, v| normalize_indexed_value(v) }
          else
            # Recursively normalize nested hashes
            value.transform_values { |v| normalize_indexed_value(v) }
          end
        when Array
          # Recursively normalize array elements
          value.map { |v| normalize_indexed_value(v) }
        else
          value
        end
      end
    end
  end
end
