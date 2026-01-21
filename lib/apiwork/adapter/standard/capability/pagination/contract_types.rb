# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ContractTypes < Adapter::Capability::ContractTypes::Base
            def register(context)
              type_name = build_page_type(context)

              return unless type_name

              context.registrar.action(:index) do
                request do
                  query do
                    reference? :page, to: type_name
                  end
                end
              end
            end

            private

            def build_page_type(context)
              strategy = context.schema_class.adapter_config.pagination.strategy
              max_size = context.schema_class.adapter_config.pagination.max_size

              type_name = page_type_name(context.schema_class)

              existing_type = context.registrar.type?(type_name)
              return type_name if existing_type

              if strategy == :cursor
                context.registrar.api_registrar.object(type_name, scope: nil) do
                  string :after, optional: true
                  string :before, optional: true
                  integer :size, max: max_size, min: 1, optional: true
                end
              else
                context.registrar.api_registrar.object(type_name, scope: nil) do
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
end
