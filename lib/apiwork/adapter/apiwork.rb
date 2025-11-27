# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      option :key_format, type: :symbol, default: :keep, enum: %i[keep camel underscore]
      option :default_sort, type: :hash, default: { id: :asc }
      option :default_page_size, type: :integer, default: 20
      option :max_page_size, type: :integer, default: 200
      option :max_array_items, type: :integer, default: 1000

      def build_global_descriptors(builder, schema_data)
        DescriptorBuilder.build(builder, schema_data)
      end

      def build_contract(contract_class, schema_class, actions:)
        ContractBuilder.build(contract_class, schema_class, actions)
      end

      def render_collection(collection, schema_class, action_data)
        CollectionLoader.load(collection, schema_class, action_data.query, action_data) => { data:, metadata: }
        serialized = schema_class.serialize(data, context: action_data.context, include: action_data.query[:include])

        {
          schema_class.root_key.plural => serialized,
          pagination: metadata[:pagination],
          meta: action_data.meta.presence
        }.compact
      end

      def render_record(record, schema_class, action_data)
        return { meta: action_data.meta.presence || {} } if action_data.delete?

        data = RecordLoader.load(record, schema_class, action_data.query)
        serialized = schema_class.serialize(data, context: action_data.context, include: action_data.query[:include])

        {
          schema_class.root_key.singular => serialized,
          meta: action_data.meta.presence
        }.compact
      end

      def render_error(issues, action_data)
        { issues: issues.map(&:to_h) }
      end

      def transform_request(hash, schema_class)
        format = schema_class.resolve_option(:key_format)
        transformed = transform_request_keys(hash, format)
        ParamsNormalizer.call(transformed)
      end

      def transform_response(hash, schema_class)
        format = schema_class.resolve_option(:key_format)
        transform_response_keys(hash, format)
      end

      private

      def transform_request_keys(hash, format)
        case format
        when :camel
          hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
        when :underscore
          hash
        else
          hash
        end
      end

      def transform_response_keys(hash, format)
        case format
        when :camel
          hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
        when :underscore
          hash
        else
          hash
        end
      end
    end
  end
end
