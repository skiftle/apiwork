# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'
require_relative '../transform/case'
require_relative 'action_definition'

module Apiwork
  module Contract
    class Base
      class << self
        attr_accessor :_resource_class

        def inherited(subclass)
          super
          # Initialize action definitions hash for each subclass
          subclass.instance_variable_set(:@action_definitions, {})
          # Initialize custom types hash for each subclass
          subclass.instance_variable_set(:@custom_types, {})
        end

        # DSL method for explicit resource declaration
        # Accepts Class, String, or Symbol for lazy loading
        def resource(ref)
          @_resource_class = ref
        end

        # Get resource class (must be explicit)
        def resource_class
          return nil unless defined?(@_resource_class)

          resolve_resource_ref(@_resource_class)
        end

        # Check if this contract uses a resource
        def uses_resource?
          resource_class.present?
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

          # Auto-generate action if we have a resource (for any action, not just CRUD)
          if resource_class
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
          action_def = ActionDefinition.new(action_name, self)
          @action_definitions[action_name.to_sym] = action_def
        end

        # Resolve resource reference (Class, String, or Symbol)
        def resolve_resource_ref(ref)
          case ref
          when nil then nil
          when Class then ref
          when String then ref.constantize
          when Symbol then ref.to_s.camelize.constantize
          else
            raise ArgumentError, "resource must be a Class, String, Symbol, or nil, got #{ref.class}"
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
        params.deep_symbolize_keys
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
    end
  end
end
