# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class CursorPaginator
          def self.paginate(relation, schema_class, params)
            new(relation, schema_class, params).paginate
          end

          def initialize(relation, schema_class, params)
            @relation = relation
            @schema_class = schema_class
            @params = params
          end

          def paginate
            page_size = resolve_page_size
            records = fetch_records(page_size)

            has_more = records.size > page_size
            records = records.first(page_size)

            metadata = build_metadata(records, has_more)

            [records, metadata]
          end

          private

          def fetch_records(page_size)
            table = @relation.klass.arel_table
            pk_column = table[primary_key]

            if @params[:after]
              cursor_data = decode_cursor(@params[:after])
              @relation.where(pk_column.gt(cursor_data[primary_key])).order(pk_column.asc).limit(page_size + 1).to_a
            elsif @params[:before]
              cursor_data = decode_cursor(@params[:before])
              records = @relation.where(pk_column.lt(cursor_data[primary_key])).order(pk_column.desc).limit(page_size + 1).to_a
              records.reverse
            else
              @relation.order(pk_column.asc).limit(page_size + 1).to_a
            end
          end

          def resolve_page_size
            @params.fetch(:size, default_page_size).to_i
          end

          def default_page_size
            @schema_class.resolve_option(:pagination, :default_size)
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
                next_cursor: has_more && records.any? ? encode_cursor(records.last) : nil,
                prev_cursor: (@params[:after] || @params[:before]) && records.any? ? encode_cursor(records.first) : nil
              }
            }
          end

          def encode_cursor(record)
            Base64.urlsafe_encode64({ primary_key => record.public_send(primary_key) }.to_json)
          end

          def decode_cursor(cursor)
            JSON.parse(Base64.urlsafe_decode64(cursor)).symbolize_keys
          rescue ArgumentError, JSON::ParserError
            issue = ::Apiwork::Issue.new(code: 'invalid_cursor', path: [:page], detail: 'Invalid cursor format')
            raise ::Apiwork::ConstraintError, issue
          end
        end
      end
    end
  end
end
