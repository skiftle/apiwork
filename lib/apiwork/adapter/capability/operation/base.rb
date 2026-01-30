# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Operation
        # @api public
        # Base class for capability Operation phase.
        #
        # Operation phase runs on each request.
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
            # Sets the scope for this operation.
            #
            # @param value [Symbol, nil] :collection or :record
            # @return [Symbol, nil] the current scope
            def scope(value = nil)
              @scope = value if value
              @scope
            end

            # @api public
            # Defines metadata shape for this operation.
            #
            # The block receives a shape builder with access to type DSL methods
            # and capability options.
            #
            # @yield [shape] block that defines metadata structure
            # @yieldparam shape [Capability::Shape] shape builder with options
            # @return [Proc, nil] the metadata block
            #
            # @example
            #   metadata do |shape|
            #     shape.reference(:pagination, to: :offset_pagination)
            #   end
            def metadata(&block)
              @metadata_block = block if block
              @metadata_block
            end
          end

          def initialize(data, representation_class, options, request)
            @data = data
            @representation_class = representation_class
            @options = options
            @request = request
          end

          # @api public
          # Applies this operation to the data.
          #
          # Override this method to implement transformation logic.
          # Return nil if no changes are made.
          #
          # @return [Result, nil] the result or nil for no changes
          def apply
            raise NotImplementedError
          end

          # @api public
          # Creates a result object.
          #
          # @param data [Object, nil] transformed data
          # @param metadata [Hash, nil] metadata to add to response
          # @param includes [Array, nil] associations to preload
          # @param serialize_options [Hash, nil] options for serialization
          # @return [Result]
          def result(data: nil, includes: nil, metadata: nil, serialize_options: nil)
            Result.new(
              data:,
              includes:,
              metadata:,
              serialize_options:,
            )
          end
        end
      end
    end
  end
end
