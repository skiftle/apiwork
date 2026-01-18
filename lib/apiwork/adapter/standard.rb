# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      option :pagination, type: :hash do
        option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
        option :default_size, default: 20, type: :integer
        option :max_size, default: 100, type: :integer
      end

      def register_api(registrar, capabilities)
        APIBuilder.build(registrar, capabilities)
      end

      def register_contract(registrar, schema_class, actions)
        ContractBuilder.build(registrar, schema_class, actions)
      end

      def render_collection(collection, schema_class, state)
        CollectionLoader.load(collection, schema_class, state) => { data:, metadata: }
        data = schema_class.serialize(data, context: state.context, include: state.query[:include])

        {
          schema_class.root_key.plural => data,
          pagination: metadata[:pagination],
          meta: state.meta.presence,
        }.compact
      end

      def render_record(record, schema_class, state)
        RecordValidator.validate!(record, schema_class)

        data = RecordLoader.load(record, schema_class, state.query)
        data = schema_class.serialize(data, context: state.context, include: state.query[:include])

        {
          schema_class.root_key.singular => data,
          meta: state.meta.presence,
        }.compact
      end

      def render_error(layer, issues, state)
        {
          layer:,
          issues: issues.map(&:to_h),
        }
      end

      def normalize_request(request)
        RequestContext.new(
          body: RequestTransformer.transform(request.body),
          query: RequestTransformer.transform(request.query),
        )
      end

      def prepare_request(request)
        RequestContext.new(
          body: transform_nested_op_fields(request.body),
          query: transform_nested_op_fields(request.query),
        )
      end

      private

      def transform_nested_op_fields(params)
        return params unless params.is_a?(Hash)

        params.transform_values do |value|
          case value
          when Hash
            transform_op_field(transform_nested_op_fields(value))
          when Array
            value.map { |item| item.is_a?(Hash) ? transform_op_field(transform_nested_op_fields(item)) : item }
          else
            value
          end
        end
      end

      def transform_op_field(hash)
        return hash unless hash.key?(:_op)

        op = hash.delete(:_op)
        hash[:_destroy] = true if op == 'delete'
        hash
      end
    end
  end
end
