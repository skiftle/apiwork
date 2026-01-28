# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Base
        attr_reader :capabilities, :data, :document, :meta, :representation_class

        class << self
          def document_type(value = nil)
            if value
              @document_type = value
            elsif defined?(@document_type)
              @document_type
            elsif superclass.respond_to?(:document_type)
              superclass.document_type
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

              def build
                block = self.class.instance_variable_get(:@callable)
                block.arity.positive? ? block.call(self) : instance_exec(&block)
              end
            end
          end
        end

        def initialize(representation_class, data, document, capabilities, meta)
          @representation_class = representation_class
          @data = data
          @document = document
          @capabilities = capabilities
          @meta = meta
        end

        def build
          json.merge(document).compact
        end

        def json
          raise NotImplementedError
        end
      end
    end
  end
end
