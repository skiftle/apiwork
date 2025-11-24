# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      module Helpers
        class << self
          def sti_base_schema?(schema_class)
            return false unless schema_class.respond_to?(:sti_base?) && schema_class.sti_base?

            schema_class.respond_to?(:variants) && schema_class.variants&.any?
          end

          def resolve_association_resource(association_definition)
            return :polymorphic if association_definition.polymorphic?

            if association_definition.schema_class
              resolved_schema = if association_definition.schema_class.is_a?(Class)
                                  association_definition.schema_class
                                else
                                  begin
                                    association_definition.schema_class.constantize
                                  rescue NameError
                                    nil
                                  end
                                end

              return { sti: true, schema: resolved_schema } if resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?

              return resolved_schema
            end

            model_class = association_definition.model_class
            return nil unless model_class

            reflection = model_class.reflect_on_association(association_definition.name)
            return nil unless reflection

            association_model_class = begin
              reflection.klass
            rescue ActiveRecord::AssociationNotFoundError, NameError
              nil
            end
            return nil unless association_model_class

            model_name = association_model_class.name.demodulize
            resolved_schema = try_resolve_schema_class(model_name)

            return { sti: true, schema: resolved_schema } if resolved_schema.respond_to?(:sti_base?) && resolved_schema.sti_base?

            resolved_schema
          end

          def auto_import_association_contract(parent_contract, association_schema, visited)
            return nil if visited.include?(association_schema)

            association_contract = Contract::Base.find_contract_for_schema(association_schema)
            return nil unless association_contract

            alias_name = association_schema.root_key.singular.to_sym

            parent_contract.import(association_contract, as: alias_name) unless parent_contract.imports.key?(alias_name)

            if association_contract.schema?
              TypeBuilder.build_filter_type(association_contract, association_schema, visited: visited, depth: 0)
              TypeBuilder.build_sort_type(association_contract, association_schema, visited: visited, depth: 0)
              TypeBuilder.build_include_type(association_contract, association_schema, visited: visited, depth: 0)
              TypeBuilder.build_nested_payload_union(association_contract, association_schema)
              TypeBuilder.build_response_type(association_contract, association_schema, visited: visited)
            end

            alias_name
          end

          def try_resolve_schema_class(model_name)
            schema_patterns = [
              "#{model_name}Schema",
              "Api::V1::#{model_name}Schema",
              "Api::#{model_name}Schema"
            ]

            schema_patterns.each do |pattern|
              return pattern.constantize
            rescue NameError
              next
            end

            nil
          end

          def build_type_name(schema_class, base_name, depth)
            return base_name if depth.zero?

            schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
            :"#{schema_name}_#{base_name}"
          end
        end
      end
    end
  end
end
