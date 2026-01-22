# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Base
        class << self
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

              def build
                builder = ShapeBuilder.new(target, context)
                builder.instance_exec(&self.class.instance_variable_get(:@callable))
              end
            end
          end
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
