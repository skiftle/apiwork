# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps resource definitions.
      #
      # @see Action
      # @example
      #   data.resources.each do |resource|
      #     resource.name       # => :invoices
      #     resource.identifier # => "invoices"
      #     resource.path       # => "invoices"
      #     resource.nested?    # => true if has nested resources
      #
      #     resource.actions.each do |action|
      #       # ...
      #     end
      #
      #     resource.resources.each do |nested|
      #       # ...
      #     end
      #   end
      class Resource
        attr_reader :name

        def initialize(name, data)
          @name = name.to_sym
          @data = data || {}
        end

        # @return [String] resource identifier
        def identifier
          @data[:identifier]
        end

        # @return [String] URL path segment
        def path
          @data[:path]
        end

        # @return [Array<Action>] actions defined on this resource
        # @see Action
        def actions
          @actions ||= (@data[:actions] || {}).map do |action_name, action_data|
            Action.new(action_name, action_data)
          end
        end

        # @return [Array<Resource>] nested resources
        # @see Resource
        def resources
          @resources ||= (@data[:resources] || {}).map do |resource_name, resource_data|
            Resource.new(resource_name, resource_data)
          end
        end

        # @return [Boolean] whether this resource has nested resources
        def nested?
          resources.any?
        end

        # @return [Hash, nil] schema definition if this resource has a schema
        def schema
          @data[:schema]
        end

        # @return [Boolean] whether this resource has a schema
        def schema?
          schema.present?
        end

        # Iterates over all actions.
        #
        # @yieldparam action [Action] each action
        # @see Action
        def each_action(&block)
          actions.each(&block)
        end

        # @return [Hash] the raw underlying data hash
        def to_h
          @data
        end
      end
    end
  end
end
