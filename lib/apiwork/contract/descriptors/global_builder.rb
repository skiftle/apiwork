# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      # GlobalBuilder: DSL for registering global descriptors (types and enums)
      #
      # Provides a clean DSL for descriptor registration:
      #
      #   Apiwork.register_global_descriptors do
      #     type :string_filter do
      #       param :eq, type: :string
      #       param :ne, type: :string
      #     end
      #
      #     enum :status, %w[draft published archived]
      #   end
      #
      # The builder evaluates the block and registers each descriptor
      # with the Descriptors registry.
      #
      class GlobalBuilder
        # Define a global type
        #
        # @param name [Symbol] Type name
        # @param options [Hash] Type options (reserved for future use)
        # @param block [Proc] Type definition block
        def type(name, **options, &block)
          Registry.register_global(name, &block)
        end

        # Define a global enum
        #
        # @param name [Symbol] Enum name
        # @param values [Array] Enum values
        #
        # @example
        #   Apiwork.register_global_descriptors do
        #     enum :status, %w[draft published archived]
        #   end
        def enum(name, values)
          raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

          Registry.register_global_enum(name, values)
        end
      end
    end
  end
end
