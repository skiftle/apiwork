# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class GlobalBuilder
        def type(name, **options, &block)
          Registry.register_global(name, &block)
        end

        def enum(name, values)
          raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

          Registry.register_global_enum(name, values)
        end
      end
    end
  end
end
