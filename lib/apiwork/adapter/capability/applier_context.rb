# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      # @api public
      # Context object for runtime capability operations.
      #
      # Passed to Applier methods during request processing.
      #
      # @example Accessing context in an Applier
      #   def apply(context)
      #     paginated = paginate(context.data, context.params)
      #     ApplyResult.new(data: paginated, additions: { pagination: stats })
      #   end
      class ApplierContext
        # @api public
        # @return [Object] the HTTP request
        attr_reader :request

        # @api public
        # @return [Class] the schema class
        attr_reader :schema_class

        # @api public
        # @return [Object] the current action
        attr_reader :action

        # @api public
        # @return [Object] the data to transform (set after preload)
        attr_accessor :data

        # @api public
        # @return [Hash] extracted params (set after extract)
        attr_accessor :params

        def initialize(action:, request:, schema_class:)
          @request = request
          @schema_class = schema_class
          @action = action
        end
      end
    end
  end
end
