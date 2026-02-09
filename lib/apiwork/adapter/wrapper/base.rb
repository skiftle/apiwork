# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      class Base
        class_attribute :shape_class
        class_attribute :wrapper_type

        # @api public
        # The data for this wrapper.
        #
        # @return [Hash]
        attr_reader :data

        class << self
          def wrap(...)
            new(...).wrap
          end

          # @api public
          # Defines the response shape for contract generation.
          #
          # @param klass_or_callable [Class<Shape>, Proc, nil] (nil) a Shape subclass or callable
          # @yield block that defines the shape using the Shape DSL
          # @return [Class<Shape>, nil]
          def shape(klass_or_callable = nil, &block)
            callable = block || klass_or_callable

            if callable
              self.shape_class = if callable.respond_to?(:call)
                                   wrap_callable(callable)
                                 else
                                   callable
                                 end
            end

            shape_class
          end

          private

          def wrap_callable(callable)
            Class.new(Shape) do
              define_singleton_method(:callable) { callable }

              def apply
                block = self.class.callable
                block.arity.positive? ? block.call(self) : instance_exec(&block)
              end
            end
          end
        end

        def initialize(data)
          @data = data
        end

        # @api public
        # Transforms the data into the final response format.
        #
        # @return [Hash]
        def wrap
          raise NotImplementedError
        end
      end
    end
  end
end
