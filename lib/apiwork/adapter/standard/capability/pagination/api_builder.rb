# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ApiBuilder < Adapter::Capability::ApiBuilder::Base
            def build
              return unless capabilities.index_actions?

              register_offset_pagination if configured(:strategy).include?(:offset)
              register_cursor_pagination if configured(:strategy).include?(:cursor)
            end

            private

            def register_offset_pagination
              object :offset_pagination do
                integer :current
                integer :next, nullable: true, optional: true
                integer :prev, nullable: true, optional: true
                integer :total
                integer :items
              end
            end

            def register_cursor_pagination
              object :cursor_pagination do
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
