# frozen_string_literal: true

module Apiwork
  module Resource
    module Querying
      module IncludesValidation
        extend ActiveSupport::Concern

        class_methods do
          # Validate and transform include params
          # Input: { comments: true } or { comments: { author: true } }
          # Output: :comments or { comments: { author: true } }
          def validate_includes(includes_param)
            return nil if includes_param.blank?
            return nil unless includes_param.is_a?(Hash)

            transform_includes(includes_param, self)
          rescue ArgumentError => e
            raise Apiwork::Error.new(e.message)
          end

          private

          def transform_includes(includes_hash, resource_class, path = [])
            result = {}

            includes_hash.each do |key, value|
              key = key.to_sym
              current_path = path + [key]

              # Check if association exists
              assoc_def = resource_class.association_definitions[key]
              unless assoc_def
                available = resource_class.association_definitions
                  .select { |_, definition| !definition.serializable? }
                  .keys
                  .join(', ')

                raise ArgumentError.new(
                  "Association '#{key}' does not exist on #{resource_class.name}. " \
                  "Available for inclusion: #{available.presence || 'none'}"
                )
              end

              # Check if association is already always included
              if assoc_def.serializable?
                raise ArgumentError.new(
                  "Association '#{key}' on #{resource_class.name} is always included (serializable: true)"
                )
              end

              # Get the associated resource class for nested validation
              associated_resource = assoc_def.resource_class
              if associated_resource.is_a?(String)
                associated_resource = associated_resource.constantize
              end

              # Handle nested includes
              if value.is_a?(Hash)
                unless associated_resource
                  raise ArgumentError.new(
                    "Cannot resolve resource class for association '#{key}' on #{resource_class.name}"
                  )
                end

                nested = transform_includes(value, associated_resource, current_path)
                result[key] = nested
              elsif value == true || value == 'true'
                # Simple include: { comments: true } → :comments
                result[key] = true
              else
                raise ArgumentError.new(
                  "Invalid value for include '#{key}'. Expected true or nested hash, got: #{value.class}"
                )
              end
            end

            result
          end
        end
      end
    end
  end
end
