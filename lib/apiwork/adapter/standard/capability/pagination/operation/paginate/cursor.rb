# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation
            module Paginate
              class Cursor
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
                  size = @params.fetch(:size, @config.default_size).to_i
                  records = fetch_records(size)
                  has_more = records.length > size
                  records = records.first(size)

                  { data: records, metadata: build_metadata(records, has_more) }
                end

                private

                def fetch_records(size)
                  table = @relation.klass.arel_table
                  column = table[primary_key]

                  if @params[:after]
                    cursor_value = decode_cursor(@params[:after], field: :after)[primary_key]
                    @relation.where(column.gt(cursor_value)).order(column.asc).limit(size + 1).to_a
                  elsif @params[:before]
                    cursor_value = decode_cursor(@params[:before], field: :before)[primary_key]
                    @relation.where(column.lt(cursor_value)).order(column.desc).limit(size + 1).to_a.reverse
                  else
                    @relation.order(column.asc).limit(size + 1).to_a
                  end
                end

                def primary_key
                  return @primary_key if defined?(@primary_key)

                  key = @relation.klass.primary_key
                  raise NotImplementedError, 'Cursor pagination does not support composite primary keys' if key.is_a?(Array)

                  @primary_key = key.to_sym
                end

                def build_metadata(records, has_more)
                  {
                    pagination: {
                      next: has_more && records.any? ? encode_cursor(records.last) : nil,
                      prev: (@params[:after] || @params[:before]) && records.any? ? encode_cursor(records.first) : nil,
                    },
                  }
                end

                def encode_cursor(record)
                  Base64.urlsafe_encode64({ primary_key => record.public_send(primary_key) }.to_json)
                end

                def decode_cursor(cursor, field:)
                  JSON.parse(Base64.urlsafe_decode64(cursor)).symbolize_keys
                rescue ArgumentError, JSON::ParserError
                  issue = Issue.new(:value_invalid, 'Invalid value', meta: { field:, expected: 'cursor' }, path: [:page, field])
                  raise ContractError, issue
                end
              end
            end
          end
        end
      end
    end
  end
end
