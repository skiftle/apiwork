# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape do
            reference context.schema_class.root_key.singular.to_sym
            context.capability_shapes.each_value(&method(:merge!))
            object? :meta
          end

          def build
            json = {
              schema_class.root_key.singular.to_sym => data,
              meta: meta.presence,
            }

            run_build_blocks(json, :record)

            json.compact
          end

          private

          def run_build_blocks(json, document_type)
            capabilities.each do |capability|
              klass = capability.class.computation_class
              next unless klass

              envelope = klass.envelope
              next unless envelope&.build_block

              scope = klass.scope
              next if scope && scope != document_type

              context = Capability::Computation::BuildContext.new(
                additions:,
                json:,
                schema_class:,
                options: capability.config,
              )
              context.instance_exec(&envelope.build_block)
            end
          end
        end
      end
    end
  end
end
