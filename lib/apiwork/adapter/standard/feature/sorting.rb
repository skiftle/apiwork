# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Sorting < Adapter::Feature
          feature_name :sorting
          applies_to :index
          input :collection

          option :max_depth, default: 2, type: :integer

          def api(registrar, capabilities)
            return unless capabilities.sortable?

            registrar.enum :sort_direction, values: %w[asc desc]
          end

          def contract(registrar, schema_class)
            TypeBuilder.build(registrar, schema_class)
          end

          def extract(request, schema_class)
            request&.query&.dig(:sort)
          end

          def includes(params, schema_class)
            return [] if params.blank?

            IncludesResolver::AssociationExtractor.new(schema_class).extract_from_sort(params).keys
          end

          def apply(data, params, context)
            issues = []
            sorted = Sorter.sort(data[:data], context.schema_class, params, issues)

            raise ContractError, issues if issues.any?

            data.merge(data: sorted)
          end
        end
      end
    end
  end
end
