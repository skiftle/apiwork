# frozen_string_literal: true

module Apiwork
  module Contract
    # GlobalTypeBuilder: DSL for registering global types
    #
    # Provides a clean DSL for type registration blocks:
    #
    #   Apiwork.register_global_types do
    #     type :string_filter do
    #       param :eq, type: :string
    #       param :ne, type: :string
    #     end
    #   end
    #
    # The builder evaluates the block and registers each type
    # with the TypeRegistry.
    #
    class GlobalTypeBuilder
      # Define a global type
      #
      # @param name [Symbol] Type name
      # @param options [Hash] Type options (e.g., enum values)
      # @param block [Proc] Type definition block
      def type(name, **options, &block)
        TypeRegistry.register_global(name, &block)
      end
    end
  end
end
