# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
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
          return @record if @query[:include].blank?

          includes_hash_value = build_includes_hash(@query[:include])
          return @record if includes_hash_value.empty?

          ActiveRecord::Associations::Preloader.new(associations: includes_hash_value, records: [@record]).call
          @record
        end

        private

        def build_includes_hash(includes_param)
          IncludesResolver.new(schema_class).build(
            for_collection: false,
            params: { include: includes_param },
          )
        end
      end
    end
  end
end
