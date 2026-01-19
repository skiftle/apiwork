# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Resource < Adapter::Envelope::Resource
          class Loader
            attr_reader :schema_class

            def self.load(record, schema_class, request)
              new(record, schema_class, request).load
            end

            def initialize(record, schema_class, request)
              @record = record
              @schema_class = schema_class
              @request = request
            end

            def load
              return @record unless @record.is_a?(ActiveRecord::Base)

              include_param = @request.query[:include]
              return @record if include_param.blank?

              includes_hash_value = build_includes_hash(include_param)
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
  end
end
