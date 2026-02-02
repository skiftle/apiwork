# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      class Base
        attr_reader :data

        class << self
          def wrapper_type(value = nil)
            if value
              @wrapper_type = value
            elsif defined?(@wrapper_type)
              @wrapper_type
            elsif superclass.respond_to?(:wrapper_type)
              superclass.wrapper_type
            end
          end

          def shape(klass_or_callable = nil, &block)
            callable = block || klass_or_callable

            if callable
              @shape_class = if callable.respond_to?(:call)
                               wrap_callable(callable)
                             else
                               callable
                             end
            end

            @shape_class
          end

          attr_reader :shape_class

          private

          def wrap_callable(callable)
            Class.new(Shape) do
              @callable = callable

              def apply
                block = self.class.instance_variable_get(:@callable)
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
