# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      # @api public
      # Wraps resource definitions.
      #
      # @example
      #   api.resources[:invoices].path              # => "invoices"
      #   api.resources[:invoices].parent_identifiers # => []
      #   api.resources[:invoices].resources         # => {} or nested resources
      #
      #   api.each_resource do |resource|
      #     resource.identifier         # => "invoices"
      #     resource.parent_identifiers # => [] or ["posts"] for nested
      #
      #     resource.actions.each_value do |action|
      #       action.request  # => Action::Request or nil
      #       action.response # => Action::Response or nil
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
        # @return [Array<String>] parent resource identifiers
        def parent_identifiers
          @data[:parent_identifiers] || []
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
            parent_identifiers: parent_identifiers,
            path: path,
            resources: resources.transform_values(&:to_h),
          }
        end
      end
    end
  end
end
