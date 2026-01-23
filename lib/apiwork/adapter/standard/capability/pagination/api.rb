# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class API < Adapter::Capability::API::Base
            def build
              return unless index_actions?

              if configured(:strategy).include?(:offset)
                object :offset_pagination do
                  integer :current
                  integer? :next, nullable: true
                  integer? :prev, nullable: true
                  integer :total
                  integer :items
                end
              end

              return unless configured(:strategy).include?(:cursor)

              object :cursor_pagination do
                string? :next, nullable: true
                string? :prev, nullable: true
              end
            end
          end
        end
      end
    end
  end
end
