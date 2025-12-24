# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Registers API-wide types during adapter initialization.
    #
    # Passed to `register_api_types` in your adapter. Use to define
    # shared types like pagination, error responses, or enums.
    #
    # @example Register pagination type
    #   def register_api_types(type_registrar, schema_data)
    #     type_registrar.type :pagination do
    #       param :page, type: :integer
    #       param :per_page, type: :integer
    #       param :total, type: :integer
    #     end
    #   end
    #
    # @example Register enum
    #   def register_api_types(type_registrar, schema_data)
    #     type_registrar.enum :status, values: %w[pending active completed]
    #   end
    class APIRegistrar
      def initialize(api_class)
        @api_class = api_class
      end

      # @!method type(name, &block)
      #   @api public
      #   Defines a named type.
      #   @param name [Symbol] the type name
      #   @yield block defining params
      #   @see Apiwork::Api::Base.type

      # @!method enum(name, values:)
      #   @api public
      #   Defines an enum type.
      #   @param name [Symbol] the enum name
      #   @param values [Array<String>] allowed values
      #   @see Apiwork::Api::Base.enum

      # @!method union(name, &block)
      #   @api public
      #   Defines a union type.
      #   @param name [Symbol] the union name
      #   @yield block defining variants
      #   @see Apiwork::Api::Base.union

      # @!method resolve_type(name)
      #   @api public
      #   Resolves a type registered at the API level.
      #   @param name [Symbol] the type name
      #   @return [Object, nil] the type definition if registered

      # @!method resolve_enum(name)
      #   @api public
      #   Resolves an enum registered at the API level.
      #   @param name [Symbol] the enum name
      #   @return [Array, nil] the enum values if registered

      delegate :type,
               :enum,
               :union,
               :resolve_type,
               :resolve_enum,
               to: :api_class

      private

      attr_reader :api_class
    end
  end
end
