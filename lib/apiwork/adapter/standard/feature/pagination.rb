# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Pagination < Adapter::Feature
          feature_name :pagination
          applies_to :index
          input :collection

          option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
          option :default_size, default: 20, type: :integer
          option :max_size, default: 100, type: :integer

          def api(registrar, capabilities)
            return unless capabilities.index_actions?

            strategies = capabilities.options_for(:pagination, :strategy)
            register_offset_pagination(registrar) if strategies.include?(:offset)
            register_cursor_pagination(registrar) if strategies.include?(:cursor)
          end

          def contract(registrar, schema_class)
            build_page_type(registrar, schema_class)
          end

          def extract(request, schema_class)
            request.query[:page] || {}
          end

          def includes(params, schema_class)
            []
          end

          def apply(data, params, context)
            collection = data[:data]
            paginated, pagination_result = paginate(collection, context.schema_class, params)

            data.merge(data: paginated, pagination: pagination_result[:pagination])
          end

          def metadata(result)
            return {} unless result.is_a?(Hash) && result.key?(:pagination)

            { pagination: result[:pagination] }
          end

          private

          def register_offset_pagination(registrar)
            registrar.object :offset_pagination do
              integer :current
              integer :next, nullable: true, optional: true
              integer :prev, nullable: true, optional: true
              integer :total
              integer :items
            end
          end

          def register_cursor_pagination(registrar)
            registrar.object :cursor_pagination do
              string :next, nullable: true, optional: true
              string :prev, nullable: true, optional: true
            end
          end

          def paginate(collection, schema_class, page_params)
            strategy = schema_class.adapter_config.pagination.strategy

            case strategy
            when :offset
              OffsetPaginator.paginate(collection, schema_class, page_params)
            else
              CursorPaginator.paginate(collection, schema_class, page_params)
            end
          end

          def build_page_type(registrar, schema_class)
            strategy = schema_class.adapter_config.pagination.strategy
            max_size = schema_class.adapter_config.pagination.max_size

            type_name = page_type_name(schema_class)

            existing_type = registrar.type?(type_name)
            return type_name if existing_type

            if strategy == :cursor
              registrar.api_registrar.object(type_name, scope: nil) do
                string :after, optional: true
                string :before, optional: true
                integer :size, max: max_size, min: 1, optional: true
              end
            else
              registrar.api_registrar.object(type_name, scope: nil) do
                integer :number, min: 1, optional: true
                integer :size, max: max_size, min: 1, optional: true
              end
            end

            type_name
          end

          def page_type_name(schema_class)
            schema_name = schema_class.name.demodulize.delete_suffix('Schema').underscore
            :"#{schema_name}_page"
          end
        end
      end
    end
  end
end
