# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              return unless actions.key?(:index)

              strategy = options.strategy
              max = options.max_size

              object :page do
                if strategy == :cursor
                  string? :after
                  string? :before
                else
                  integer? :number, min: 1
                end
                integer? :size, max:, min: 1
              end

              action :index do
                request do
                  query do
                    reference? :page
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
