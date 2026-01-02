# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      # @api public
      # Wraps resource definitions.
      #
      # @example
      #   api.resources.each do |resource|
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
        # @api public
        # @return [Symbol] resource name
        attr_reader :name

        def initialize(name, data)
          @name = name.to_sym
          @data = data
        end

        # @api public
        # @return [String] resource identifier
        def identifier
          @data[:identifier]
        end

        # @api public
        # @return [String] URL path segment
        def path
          @data[:path]
        end

        # @api public
        # @return [Array<Action>] actions defined on this resource
        # @see Action
        def actions
          @actions ||= @data[:actions].map do |action_name, action_data|
            Action.new(action_name, action_data)
          end
        end

        # @api public
        # @return [Array<Resource>] nested resources
        def resources
          @resources ||= @data[:resources].map do |resource_name, resource_data|
            Resource.new(resource_name, resource_data)
          end
        end

        # @api public
        # @return [Boolean] whether this resource has nested resources
        def nested?
          resources.any?
        end

        # @api public
        # Iterates over all actions.
        #
        # @yieldparam action [Action] each action
        # @see Action
        def each_action(&block)
          actions.each(&block)
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          {
            actions: actions.map(&:to_h),
            identifier: identifier,
            name: name,
            path: path,
            resources: resources.map(&:to_h),
          }
        end
      end
    end
  end
end
