# frozen_string_literal: true

module Apiwork
  module Introspection
    class API
      # @api public
      # Wraps resource definitions.
      #
      # @example
      #   resource = api.resources[:invoices]
      #
      #   resource.identifier         # => "invoices"
      #   resource.path               # => "invoices"
      #   resource.parent_identifiers # => []
      #   resource.resources          # => {} or nested resources
      #
      #   resource.actions.each_value do |action|
      #     action.request  # => Action::Request
      #     action.response # => Action::Response
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
          @data[:parent_identifiers]
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
