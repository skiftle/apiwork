# frozen_string_literal: true

module Apiwork
  module Adapter
    module Builder
      module API
        # @api public
        # Base class for API-phase type builders.
        #
        # API phase runs once per API at initialization time.
        # Use it to register shared types used across all contracts.
        #
        # @example
        #   class Builder
        #     class API < Adapter::Builder::API::Base
        #       def build
        #         enum :status, values: %w[active inactive]
        #         object(:error) { |object| object.string(:message) }
        #       end
        #     end
        #   end
        class Base
          attr_reader :data_type

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :api_class

          def initialize(api_class, data_type: nil)
            @api_class = api_class
            @data_type = data_type
          end

          # @api public
          # Builds API-level types.
          #
          # Override this method to register shared types.
          # @return [void]
          def build
            raise NotImplementedError
          end

          private

          attr_reader :api_class
        end
      end
    end
  end
end
