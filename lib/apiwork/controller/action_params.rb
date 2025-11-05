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

          # If the association key exists in params, transform it
          if transformed.key?(name)
            value = transformed.delete(name)

            # Get the nested resource class for recursive transformation
            nested_resource = if assoc_def.resource_class.is_a?(String)
              assoc_def.resource_class.constantize rescue nil
            else
              assoc_def.resource_class
            end

            # Recursively transform nested associations
            if value.is_a?(Array)
              # has_many association
              transformed["#{name}_attributes".to_sym] = value.map do |nested_params|
                if nested_params.is_a?(Hash) && nested_resource
                  transform_nested_attributes(nested_params, nested_resource, action)
                else
                  nested_params
                end
              end
            elsif value.is_a?(Hash)
              # belongs_to or has_one association
              transformed["#{name}_attributes".to_sym] = if nested_resource
                transform_nested_attributes(value, nested_resource, action)
              else
                value
              end
            else
              # Scalar value (shouldn't happen for associations, but handle gracefully)
              transformed["#{name}_attributes".to_sym] = value
            end
          end
        end

        transformed
      end
    end
  end
end
