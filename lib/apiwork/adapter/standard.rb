# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      def build_global_descriptors(builder, schema_data)
        DescriptorBuilder.new(builder, schema_data)
      end

      def build_contract(contract_class, schema_class, context)
        ContractBuilder.new(contract_class, schema_class, context)
      end

      def collection_scope(collection, schema_class, query, context)
        return collection unless context.index?
        return collection unless collection.is_a?(ActiveRecord::Relation)

        Query.new(collection, schema_class).perform(query)
      end

      def record_scope(record, schema_class, query, context)
        return record unless record.is_a?(ActiveRecord::Base)

        includes_param = query[:include]
        return record if includes_param.blank?

        includes_hash_value = build_includes_hash(schema_class, includes_param)
        return record if includes_hash_value.empty?

        ActiveRecord::Associations::Preloader.new(records: [record], associations: includes_hash_value).call
        record
      end

      def render_collection(collection, meta, query, schema_class, context)
        root_key = schema_class.root_key.plural

        response = { root_key => collection }
        response[:meta] = meta if meta.present?
        response
      end

      def render_record(record, meta, query, schema_class, context)
        return { meta: meta.presence || {} } if context.delete?

        root_key = schema_class.root_key.singular

        response = { root_key => record }
        response[:meta] = meta if meta.present?
        response
      end

      def render_error(issues, context)
        { issues: issues.map(&:to_h) }
      end

      private

      def build_includes_hash(schema_class, includes_param)
        Query::IncludesResolver.new(schema: schema_class).build(
          params: { include: includes_param },
          for_collection: false
        )
      end
    end
  end
end
