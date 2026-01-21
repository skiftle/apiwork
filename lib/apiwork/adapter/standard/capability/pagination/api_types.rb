# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ApiTypes < Adapter::Capability::ApiTypes::Base
            def register(context)
              return unless context.capabilities.index_actions?

              strategies = context.capabilities.options_for(:pagination, :strategy)
              register_offset_pagination(context.registrar) if strategies.include?(:offset)
              register_cursor_pagination(context.registrar) if strategies.include?(:cursor)
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
          end
        end
      end
    end
  end
end
