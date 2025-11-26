# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class RecordLoader
        attr_reader :schema_class

        def self.load(record, schema_class, query)
          new(record, schema_class, query).load
        end

        def initialize(record, schema_class, query)
          @record = record
          @schema_class = schema_class
          @query = query
        end

        def load
          return @record unless @record.is_a?(ActiveRecord::Base)

          includes_param = @query[:include]
          return @record if includes_param.blank?

          includes_hash_value = build_includes_hash(includes_param)
          return @record if includes_hash_value.empty?

          ActiveRecord::Associations::Preloader.new(records: [@record], associations: includes_hash_value).call
          @record
        end

        private

        def build_includes_hash(includes_param)
          CollectionLoader::IncludesResolver.new(schema: schema_class).build(
            params: { include: includes_param },
            for_collection: false
          )
        end
      end
    end
  end
end
