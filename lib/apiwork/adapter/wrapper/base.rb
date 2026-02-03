# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      class Base
        class_attribute :shape_class

        attr_reader :data

        class << self
          def wrapper_type(value = nil)
            @wrapper_type = value if value
            @wrapper_type || (superclass.respond_to?(:wrapper_type) && superclass.wrapper_type)
          end

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

        def wrap
          raise NotImplementedError
        end
      end
    end
  end
end
