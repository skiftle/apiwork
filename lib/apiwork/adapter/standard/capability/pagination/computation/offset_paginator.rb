# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Computation < Adapter::Capability::Computation::Base
            class OffsetPaginator
              def self.paginate(relation, config, params)
                new(relation, config, params).paginate
              end

              def initialize(relation, config, params)
                @relation = relation
                @config = config
                @params = params
              end

              def paginate
                page_number = @params.fetch(:number, 1).to_i
                limit = resolve_limit

                [
                  @relation.limit(limit).offset((page_number - 1) * limit),
                  build_metadata(page_number, limit),
                ]
              end

              private

              def resolve_limit
                [@params.fetch(:size, @config.default_size).to_i, 1].max
              end

              def build_metadata(page_number, limit)
                items = count_items
                total = (items.to_f / limit).ceil

                {
                  items:,
                  total:,
                  current: page_number,
                  next: (page_number < total ? page_number + 1 : nil),
                  prev: (page_number > 1 ? page_number - 1 : nil),
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
