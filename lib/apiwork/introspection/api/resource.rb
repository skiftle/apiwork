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
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # @return [String]
        def identifier
          @dump[:identifier]
        end

        # @api public
        # @return [String] URL path segment
        def path
          @dump[:path]
        end

        # @api public
        # @return [Array<String>]
        def parent_identifiers
          @dump[:parent_identifiers]
        end

        # @api public
        # @return [Hash{Symbol => Introspection::Action}]
        # @see Introspection::Action
        def actions
          @actions ||= @dump[:actions].transform_values { |dump| Action.new(dump) }
        end

        # @api public
        # @return [Hash{Symbol => Resource}]
        def resources
          @resources ||= @dump[:resources].transform_values { |dump| Resource.new(dump) }
        end

        # @api public
        # @return [Hash]
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
