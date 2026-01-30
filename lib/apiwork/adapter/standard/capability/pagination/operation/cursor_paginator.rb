# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination
          class Operation < Adapter::Capability::Operation::Base
            class CursorPaginator
              def self.paginate(relation, config, params)
                new(relation, config, params).paginate
              end

              def initialize(relation, config, params)
                @relation = relation
                @config = config
                @params = params
              end

              def paginate
                page_size = resolve_page_size
                records = fetch_records(page_size)

                has_more = records.size > page_size
                records = records.first(page_size)

                [records, build_metadata(records, has_more)]
              end

              private

              def fetch_records(page_size)
                table = @relation.klass.arel_table
                pk_column = table[primary_key]

                if @params[:after]
                  cursor_value = decode_cursor(@params[:after])[primary_key]
                  @relation.where(pk_column.gt(cursor_value)).order(pk_column.asc).limit(page_size + 1).to_a
                elsif @params[:before]
                  cursor_value = decode_cursor(@params[:before])[primary_key]
                  @relation.where(pk_column.lt(cursor_value)).order(pk_column.desc).limit(page_size + 1).to_a.reverse
                else
                  @relation.order(pk_column.asc).limit(page_size + 1).to_a
                end
              end

              def resolve_page_size
                @params.fetch(:size, @config.default_size).to_i
              end

              def primary_key
                return @primary_key if defined?(@primary_key)

                pk = @relation.klass.primary_key
                raise NotImplementedError, 'Cursor pagination does not support composite primary keys' if pk.is_a?(Array)

                @primary_key = pk.to_sym
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

              def decode_cursor(cursor)
                JSON.parse(Base64.urlsafe_decode64(cursor)).symbolize_keys
              rescue ArgumentError, JSON::ParserError
                issue = Issue.new(:cursor_invalid, 'Invalid cursor', meta: { cursor: }, path: [:page])
                raise ContractError, issue
              end
            end
          end
        end
      end
    end
  end
end
