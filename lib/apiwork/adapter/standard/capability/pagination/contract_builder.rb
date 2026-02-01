# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ContractBuilder < Adapter::Capability::Contract::Base
            def build
              return unless context.action?(:index)

              object(:page) do |object|
                if options.strategy == :cursor
                  object.string?(:after)
                  object.string?(:before)
                else
                  object.integer?(:number, min: 1)
                end
                object.integer?(:size, max: options.max_size, min: 1)
              end

              action(:index) do |action|
                action.request do |request|
                  request.query do |query|
                    query.reference?(:page)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
