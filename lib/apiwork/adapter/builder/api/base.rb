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
        #         object(:error) { |o| o.string(:message) }
        #       end
        #     end
        #   end
        class Base
          # @api public
          # @return [Symbol, nil] the data type name from serializer
          attr_reader :data_type

          # @api public
          # @return [Features] feature detection for the API
          attr_reader :features

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :api_class

          def initialize(api_class, features, data_type: nil)
            @api_class = api_class
            @features = features
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
