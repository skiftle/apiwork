# frozen_string_literal: true

module Apiwork
  module Descriptor
    class << self
      # DOCUMENTATION
      def reset!
        Registry.clear!
      end

      def define_type(name, api_class:, scope: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
        Builder.define_type(
          name: name,
          api_class: api_class,
          scope: scope,
          description: description,
          example: example,
          format: format,
          deprecated: deprecated,
          &block
        )
      end

      def define_enum(name, values:, api_class:, scope: nil, description: nil, example: nil, deprecated: false)
        Builder.define_enum(
          name: name,
          values: values,
          api_class: api_class,
          scope: scope,
          description: description,
          example: example,
          deprecated: deprecated
        )
      end

      def define_union(name, api_class:, scope: nil, &block)
        Builder.define_union(
          name: name,
          api_class: api_class,
          scope: scope,
          &block
        )
      end

      def register_type(name, scope: nil, api_class: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
        Registry.register_type(
          name,
          scope: scope,
          api_class: api_class,
          description: description,
          example: example,
          format: format,
          deprecated: deprecated,
          &block
        )
      end

      def register_enum(name, values, scope: nil, api_class: nil, description: nil, example: nil, deprecated: false)
        Registry.register_enum(
          name,
          values,
          scope: scope,
          api_class: api_class,
          description: description,
          example: example,
          deprecated: deprecated
        )
      end

      def register_union(name, data, scope: nil, api_class: nil)
        Registry.register_union(name, data, scope: scope, api_class: api_class)
      end

      def resolve_type(name, contract_class:, api_class: nil, scope: nil)
        Registry.resolve_type(name, contract_class: contract_class, api_class: api_class, scope: scope)
      end

      def resolve_enum(name, scope:, api_class: nil)
        Registry.resolve_enum(name, scope: scope, api_class: api_class)
      end

      def scoped_type_name(scope, name)
        Registry.scoped_name(scope, name)
      end

      def scoped_enum_name(scope, name)
        EnumStore.scoped_name(scope, name)
      end
    end
  end
end
