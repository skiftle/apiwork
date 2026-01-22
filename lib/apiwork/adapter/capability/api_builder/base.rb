# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module APIBuilder
        class Base
          attr_reader :options,
                      :registrar

          # @!method enum(name, values:)
          #   @api public
          #   Defines an enum type.
          #   @param name [Symbol] the enum name
          #   @param values [Array<String>] allowed values

          # @!method enum?(name)
          #   @api public
          #   Checks if an enum is registered.
          #   @param name [Symbol] the enum name
          #   @return [Boolean] true if enum exists

          # @!method object(name, &block)
          #   @api public
          #   Defines a named object type.
          #   @param name [Symbol] the object name
          #   @yield block defining params

          # @!method type?(name)
          #   @api public
          #   Checks if a type is registered.
          #   @param name [Symbol] the type name
          #   @return [Boolean] true if type exists

          # @!method union(name, &block)
          #   @api public
          #   Defines a union type.
          #   @param name [Symbol] the union name
          #   @yield block defining variants

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :registrar

          # @!method filter_types
          #   @api public
          #   @return [Array<Symbol>] data types used in filterable attributes

          # @!method nullable_filter_types
          #   @api public
          #   @return [Array<Symbol>] data types used in nullable filterable attributes

          # @!method sortable?
          #   @api public
          #   @return [Boolean] true if any schema has sortable attributes or associations

          # @!method filterable?
          #   @api public
          #   @return [Boolean] true if any schema has filterable attributes

          # @!method resources?
          #   @api public
          #   @return [Boolean] true if the API has any resources registered

          # @!method index_actions?
          #   @api public
          #   @return [Boolean] true if any resource has an index action

          delegate :filter_types,
                   :filterable?,
                   :index_actions?,
                   :nullable_filter_types,
                   :resources?,
                   :sortable?,
                   to: :features

          def initialize(context)
            @registrar = context.registrar
            @features = context.features
            @capability_name = context.capability_name
            @options = context.options
          end

          def build
            raise NotImplementedError
          end

          def configured(key)
            features.options_for(@capability_name, key)
          end

          private

          attr_reader :features
        end
      end
    end
  end
end
