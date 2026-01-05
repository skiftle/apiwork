# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Registers API-wide types during adapter initialization.
    #
    # Passed to `register_api` in your adapter. Use to define
    # shared types like pagination, error responses, or enums.
    #
    # @example Register pagination type
    #   def register_api(registrar, capabilities)
    #     registrar.type :pagination do
    #       param :page, type: :integer
    #       param :per_page, type: :integer
    #       param :total, type: :integer
    #     end
    #   end
    #
    # @example Register enum
    #   def register_api(registrar, capabilities)
    #     registrar.enum :status, values: %w[pending active completed]
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

      # @!method type?(name)
      #   @api public
      #   Checks if a type is registered.
      #   @param name [Symbol] the type name
      #   @return [Boolean] true if type exists

      # @!method enum?(name)
      #   @api public
      #   Checks if an enum is registered.
      #   @param name [Symbol] the enum name
      #   @return [Boolean] true if enum exists

      # @!method enum_values(name)
      #   @api public
      #   Returns the values for a registered enum.
      #   @param name [Symbol] the enum name
      #   @return [Array<String>, nil] enum values or nil

      delegate :enum,
               :enum?,
               :enum_values,
               :type,
               :type?,
               :union,
               to: :api_class

      private

      attr_reader :api_class
    end
  end
end
