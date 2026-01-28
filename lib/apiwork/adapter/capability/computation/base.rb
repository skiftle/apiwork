# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        # @api public
        # Base class for capability Computation phase.
        #
        # Computation phase runs on each request.
        # Use it to transform data at runtime.
        class Base
          # @api public
          # @return [Object] the data to transform (relation or record)
          attr_reader :data

          # @api public
          # @return [Configuration] capability options
          attr_reader :options

          # @api public
          # @return [Request] the current request
          attr_reader :request

          # @api public
          # @return [Class] the representation class for this request
          attr_reader :representation_class

          class << self
            # @api public
            # Sets the scope for this computation.
            #
            # @param value [Symbol, nil] :collection or :record
            # @return [Symbol, nil] the current scope
            def scope(value = nil)
              @scope = value if value
              @scope
            end
          end

          def initialize(data, representation_class, options, request)
            @data = data
            @representation_class = representation_class
            @options = options
            @request = request
          end

          # @api public
          # Transforms data for this capability.
          #
          # Override this method to implement transformation logic.
          # Return nil if no changes are made.
          #
          # @return [ApplyResult, nil] the result or nil for no changes
          def apply
            raise NotImplementedError
          end

          # @api public
          # Creates a result object.
          #
          # @param data [Object, nil] transformed data
          # @param document [Hash, nil] metadata to add to response
          # @param includes [Array, nil] associations to preload
          # @param serialize_options [Hash, nil] options for serialization
          # @return [ApplyResult]
          def result(data: nil, document: nil, includes: nil, serialize_options: nil)
            ApplyResult.new(
              data:,
              document:,
              includes:,
              serialize_options:,
            )
          end
        end
      end
    end
  end
end
