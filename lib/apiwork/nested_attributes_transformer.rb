# frozen_string_literal: true

module Apiwork
  # Transforms association parameters to Rails nested attributes format
  #
  # Converts:
  #   { comments: [...] } → { comments_attributes: [...] }
  #
  # This is required for Rails accepts_nested_attributes_for to work.
  # The transformation is applied recursively for nested associations.
  #
  # Usage:
  #   transformer = NestedAttributesTransformer.new(schema_class, :create)
  #   transformed = transformer.transform(params)
  #
  class NestedAttributesTransformer
    attr_reader :schema_class, :action

    def initialize(schema_class, action)
      @schema_class = schema_class
      @action = action.to_sym
    end

    # Transform params with writable associations
    #
    # @param params [Hash] Parameters to transform
    # @return [Hash] Transformed parameters with _attributes suffix
    def transform(params)
      return params unless params.is_a?(Hash)

      transformed = params.dup

      # Process each writable association
      @schema_class.association_definitions.each do |name, assoc_definition|
        next unless assoc_definition.writable_for?(@action)
        next unless transformed.key?(name)

        # NOTE: Validation of accepts_nested_attributes_for happens at schema definition time
        # in AssociationDefinition#validate_nested_attributes!

        # Transform the association
        value = transformed.delete(name)
        nested_schema = resolve_nested_schema(assoc_definition)

        transformed["#{name}_attributes".to_sym] = transform_association_value(
          value,
          nested_schema,
          @action
        )
      end

      transformed
    end

    private

    # Resolves the nested schema class from an association definition
    #
    # @param assoc_definition [AssociationDefinition] Association definition
    # @return [Class, nil] The schema class or nil
    def resolve_nested_schema(assoc_definition)
      schema_class = assoc_definition.schema_class

      if schema_class.is_a?(String)
        schema_class.constantize rescue nil
      else
        schema_class
      end
    end

    # Transforms an association value (Array or Hash) to _attributes format
    # Recursively processes nested associations
    #
    # @param value [Array, Hash, Object] The association value
    # @param nested_schema [Class, nil] The nested schema class
    # @param action [Symbol] The action name
    # @return [Array, Hash, Object] Transformed value
    def transform_association_value(value, nested_schema, action)
      case value
      when Array
        # has_many association
        value.map do |nested_params|
          if nested_params.is_a?(Hash) && nested_schema
            self.class.new(nested_schema, action).transform(nested_params)
          else
            nested_params
          end
        end
      when Hash
        # belongs_to or has_one association
        if nested_schema
          self.class.new(nested_schema, action).transform(value)
        else
          value
        end
      else
        # Scalar value (shouldn't happen for associations, but handle gracefully)
        value
      end
    end
  end
end
