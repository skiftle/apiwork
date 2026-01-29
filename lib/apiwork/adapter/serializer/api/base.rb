# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module API
        # @api public
        # Base class for serializer API phase.
        #
        # API phase runs once per API at initialization time.
        # Use it to register shared types used across all contracts.
        #
        # @example
        #   class API < Serializer::API::Base
        #     def build
        #       enum :status, values: %w[active inactive]
        #       object(:error) { |o| o.string(:message) }
        #     end
        #   end
        class Base
          # @api public
          # @return [Features] feature detection for the API
          attr_reader :features

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :api_class

          def initialize(api_class, features)
            @api_class = api_class
            @features = features
          end

          # @api public
          # Builds API-level types for this serializer.
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
