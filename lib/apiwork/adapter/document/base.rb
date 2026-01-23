# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      class Base
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
                builder = ShapeBuilder.new(target, context)
                builder.instance_exec(&self.class.instance_variable_get(:@callable))
              end
            end
          end
        end

        def build
          raise NotImplementedError
        end

        private

        def collect_capability_builds
          capabilities.each_with_object({}) do |capability, result|
            klass = capability.class.computation_class
            next unless klass

            envelope = klass.envelope
            next unless envelope&.build_block

            scope = klass.scope
            next if scope && scope != self.class.document_type

            context = Capability::Computation::BuildContext.new(
              additions:,
              schema_class:,
              options: capability.config,
            )
            build_result = context.instance_exec(&envelope.build_block)
            result.merge!(build_result) if build_result.is_a?(Hash)
          end
        end
      end
    end
  end
end
