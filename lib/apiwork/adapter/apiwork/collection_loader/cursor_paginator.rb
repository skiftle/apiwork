# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class CursorPaginator
          def self.perform(relation, schema_class, params)
            new(relation, schema_class, params).perform
          end

          def initialize(relation, schema_class, params)
            @relation = relation
            @schema_class = schema_class
            @params = params
          end

          def perform
            page_size = resolve_page_size
            records = fetch_records(page_size)

            has_more = records.size > page_size
            records = records.first(page_size)

            metadata = build_metadata(records, has_more)

            [records, metadata]
          end

          private

          def fetch_records(page_size)
            if @params[:after]
              cursor_data = decode_cursor(@params[:after])
              @relation.where('id > ?', cursor_data[:id]).order(id: :asc).limit(page_size + 1).to_a
            elsif @params[:before]
              cursor_data = decode_cursor(@params[:before])
              records = @relation.where('id < ?', cursor_data[:id]).order(id: :desc).limit(page_size + 1).to_a
              records.reverse
            else
              @relation.order(id: :asc).limit(page_size + 1).to_a
            end
          end

          def resolve_page_size
            @params.fetch(:size, default_page_size).to_i
          end

          def default_page_size
            @schema_class.resolve_option(:default_page_size)
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
            Base64.urlsafe_encode64({ id: record.id }.to_json)
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
