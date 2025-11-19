# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class TypeStore < Store
        class << self
          def register_type(name, scope: nil, api_class: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
            register(
              name,
              block,
              scope: scope,
              metadata: {
                definition: block,
                description: description,
                example: example,
                format: format,
                deprecated: deprecated
              },
              api_class: api_class
            )
          end

          def register_union(name, data, scope: nil, api_class: nil)
            register(name, data, scope: scope, metadata: {}, api_class: api_class)
          end

          def serialize(api)
            result = {}

            # Serialize from unified storage
            if api
              storage(api).each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
                # Cache the expanded payload to avoid re-expanding on every serialize call
                expanded_shape = metadata[:expanded_payload] ||= if metadata[:payload].is_a?(Hash)
                                                                   # Union or already expanded data
                                                                   metadata[:payload]
                                                                 elsif metadata[:payload].is_a?(Proc)
                                                                   # Block definition - expand it once and cache
                                                                   expand_type_definition(
                                                                     metadata[:payload],
                                                                     contract_class: metadata[:scope],
                                                                     type_name: metadata[:name]
                                                                   )
                                                                 else
                                                                   # Fallback - use metadata[:definition] if available
                                                                   expand_type_definition(
                                                                     metadata[:definition] || metadata[:payload],
                                                                     contract_class: metadata[:scope],
                                                                     type_name: metadata[:name]
                                                                   )
                                                                 end

                # Build result with shape and metadata separated
                # For union types, expanded_shape already has type: :union, variants: [...]
                # For object types, expanded_shape is a hash of fields
                result[qualified_name] = if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
                                           # Union type - merge metadata into the existing structure
                                           expanded_shape.merge(
                                             description: metadata[:description],
                                             example: metadata[:example],
                                             format: metadata[:format],
                                             deprecated: metadata[:deprecated] || false
                                           )
                                         else
                                           # Object type - wrap fields under :shape
                                           {
                                             type: :object,
                                             shape: expanded_shape,
                                             description: metadata[:description],
                                             example: metadata[:example],
                                             format: metadata[:format],
                                             deprecated: metadata[:deprecated] || false
                                           }
                                         end
              end
            end

            result
          end

          protected

          def storage_name
            :types
          end

          def resolved_value(metadata)
            metadata[:definition]
          end

          private

          def expand_type_definition(definition, contract_class: nil, type_name: nil, scope: nil)
            temp_contract = contract_class || Class.new(Apiwork::Contract::Base)

            temp_definition = Apiwork::Contract::Definition.new(
              type: :input,
              contract_class: temp_contract
            )

            temp_definition.instance_eval(&definition)
            temp_definition.as_json
          end
        end
      end
    end
  end
end
