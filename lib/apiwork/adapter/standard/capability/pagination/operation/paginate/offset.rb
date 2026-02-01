# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation < Adapter::Capability::Operation::Base
            module Paginate
              class Offset
                class << self
                  def apply(relation, config, params)
                    new(relation, config, params).apply
                  end
                end

                def initialize(relation, config, params)
                  @relation = relation
                  @config = config
                  @params = params
                end

                def apply
                  number = @params.fetch(:number, 1).to_i
                  size = [@params.fetch(:size, @config.default_size).to_i, 1].max

                  {
                    data: @relation.limit(size).offset((number - 1) * size),
                    metadata: build_metadata(number, size),
                  }
                end

                private

                def build_metadata(number, size)
                  items = count_items
                  total = (items.to_f / size).ceil

                  {
                    pagination: {
                      items:,
                      total:,
                      current: number,
                      next: (number < total ? number + 1 : nil),
                      prev: (number > 1 ? number - 1 : nil),
                    },
                  }
                end

                def count_items
                  count_result = if @relation.joins_values.any?
                                   @relation.except(:limit, :offset, :group).distinct.count(:all)
                                 else
                                   @relation.except(:limit, :offset, :group).count
                                 end

                  count_result.is_a?(Hash) ? count_result.size : count_result
                end
              end
            end
          end
        end
      end
    end
  end
end
