# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              return unless actions.key?(:index)

              max = options.max_size

              if options.strategy == :cursor
                object :page do
                  string? :after
                  string? :before
                  integer? :size, max:, min: 1
                end
              else
                object :page do
                  integer? :number, min: 1
                  integer? :size, max:, min: 1
                end
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
