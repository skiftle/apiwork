# frozen_string_literal: true

module Apiwork
  module Controller
    module ActionParams
      extend ActiveSupport::Concern

      def action_params(options = {})
        case action_name.to_sym
        when :create, :update
          # Priority: contract_class_name > resource_class_name > default
          resource = if options[:contract_class_name]
            # Get resource from contract
            contract = options[:contract_class_name].constantize
            action_def = contract.action_definition(action_name.to_sym)
            action_def.contract_class.resource_class
          elsif options[:resource_class_name]
            options[:resource_class_name].constantize
          else
            Resource::Resolver.from_controller(self.class)
          end

          # Use root_key if resource exists, otherwise return flat params
          params = if resource&.root_key
            validated_request.params[resource.root_key.singular.to_sym] || {}
          else
            # Contract without resource - params already validated and structured by contract
            validated_request.params
          end

          # Transform writable associations to _attributes format for Rails nested attributes
          if resource
            transform_nested_attributes(params, resource, action_name.to_sym)
          else
            params
          end
        else
          validated_request.params
        end
      end

      private

      # Transforms writable associations to Rails nested attributes format
      # Example: { comments: [...] } becomes { comments_attributes: [...] }
      def transform_nested_attributes(params, resource, action)
        return params unless params.is_a?(Hash)

        transformed = params.dup

        # Process each writable association
        resource.association_definitions.each do |name, assoc_def|
          next unless assoc_def.writable_for?(action)
          next unless transformed.key?(name)

          # Note: Validation of accepts_nested_attributes_for happens at resource definition time
          # in AssociationDefinition#validate_nested_attributes! (lines 113-131)

          # Transform the association
          value = transformed.delete(name)
          nested_resource = resolve_nested_resource(assoc_def)

          transformed["#{name}_attributes".to_sym] = transform_association_value(
            value,
            nested_resource,
            action
          )
        end

        transformed
      end

      # Resolves the nested resource class from an association definition
      # Handles both String and Class types
      def resolve_nested_resource(assoc_def)
        resource_class = assoc_def.resource_class

        if resource_class.is_a?(String)
          resource_class.constantize rescue nil
        else
          resource_class
        end
      end

      # Transforms an association value (Array or Hash) to _attributes format
      # Recursively processes nested associations
      def transform_association_value(value, nested_resource, action)
        case value
        when Array
          # has_many association
          value.map do |nested_params|
            if nested_params.is_a?(Hash) && nested_resource
              transform_nested_attributes(nested_params, nested_resource, action)
            else
              nested_params
            end
          end
        when Hash
          # belongs_to or has_one association
          if nested_resource
            transform_nested_attributes(value, nested_resource, action)
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
end
