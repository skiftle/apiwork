# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              type_name = build_page_type
              return unless type_name

              action(:index) do
                request do
                  query do
                    reference? :page, to: type_name
                  end
                end
              end
            end

            private

            def build_page_type
              type_name = page_type_name

              return type_name if api.type?(type_name)

              max_size = options.max_size

              if options.strategy == :cursor
                api.object(type_name) do
                  string? :after
                  string? :before
                  integer? :size, max: max_size, min: 1
                end
              else
                api.object(type_name) do
                  integer? :number, min: 1
                  integer? :size, max: max_size, min: 1
                end
              end

              type_name
            end

            def page_type_name
              schema_name = schema_class.name.demodulize.delete_suffix('Schema').underscore
              :"#{schema_name}_page"
            end
          end
        end
      end
    end
  end
end
