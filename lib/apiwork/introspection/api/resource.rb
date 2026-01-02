# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      # @api public
      # Wraps resource definitions.
      #
      # @example
      #   api.resources[:invoices].path    # => "invoices"
      #   api.resources[:invoices].nested? # => true if has nested resources
      #
      #   api.each_resource do |resource, parent_path|
      #     resource.identifier # => "invoices"
      #
      #     resource.actions.each_value do |action|
      #       action.request  # => Action::Request or nil
      #       action.response # => Action::Response or nil
      #     end
      #
      #     resource.resources.each_value do |nested|
      #       # nested resources...
      #     end
      #   end
      class Resource
        def initialize(data)
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
        # @return [Hash{Symbol => Action}] actions defined on this resource
        # @see Action
        def actions
          @actions ||= @data[:actions].transform_values { |dump| Action.new(dump) }
        end

        # @api public
        # @return [Hash{Symbol => Resource}] nested resources
        def resources
          @resources ||= @data[:resources].transform_values { |dump| Resource.new(dump) }
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
          actions.each_value(&block)
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          {
            actions: actions.transform_values(&:to_h),
            identifier: identifier,
            path: path,
            resources: resources.transform_values(&:to_h),
          }
        end
      end
    end
  end
end
