# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class APIBuilder < Adapter::Capability::API::Base
            def build
              return unless context.has_index_actions?

              if configured(:strategy).include?(:offset)
                object(:offset_pagination) do |object|
                  object.integer(:current)
                  object.integer?(:next, nullable: true)
                  object.integer?(:prev, nullable: true)
                  object.integer(:total)
                  object.integer(:items)
                end
              end

              return unless configured(:strategy).include?(:cursor)

              object(:cursor_pagination) do |object|
                object.string?(:next, nullable: true)
                object.string?(:prev, nullable: true)
              end
            end
          end
        end
      end
    end
  end
end
