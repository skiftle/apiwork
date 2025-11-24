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
        return ScopeResult.new(collection) unless context.index?
        return ScopeResult.new(collection) unless collection.is_a?(ActiveRecord::Relation)

        query_result = Query.new(collection, schema_class).perform(query)
        ScopeResult.new(query_result.result, query_result.meta)
      end

      def record_scope(record, schema_class, query, context)
        return ScopeResult.new(record) unless record.is_a?(ActiveRecord::Base)

        includes_param = query[:include]
        return ScopeResult.new(record) if includes_param.blank?

        includes_hash_value = build_includes_hash(schema_class, includes_param)
        return ScopeResult.new(record) if includes_hash_value.empty?

        ActiveRecord::Associations::Preloader.new(records: [record], associations: includes_hash_value).call
        ScopeResult.new(record)
      end

      def render_collection(scope_result, user_meta, query, schema_class, context)
        root_key = schema_class.root_key.plural
        collection = scope_result.data

        response = { root_key => collection }
        response[:pagination] = scope_result.metadata[:pagination] if scope_result.metadata[:pagination]
        response[:meta] = user_meta if user_meta.present?
        response
      end

      def render_record(scope_result, user_meta, query, schema_class, context)
        return { meta: user_meta.presence || {} } if context.delete?

        root_key = schema_class.root_key.singular
        record = scope_result.data

        response = { root_key => record }
        response[:meta] = user_meta if user_meta.present?
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
