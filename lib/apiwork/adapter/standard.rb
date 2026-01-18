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

      register do
        api { |registrar, capabilities| APIBuilder.build(registrar, capabilities) }
        contract { |registrar, schema_class, actions| ContractBuilder.build(registrar, schema_class, actions) }
      end

      request do
        before_validation do
          transform { |request| request.transform(&RequestTransformer.method(:transform)) }
        end
        after_validation do
          transform { |request| request.transform(&OpFieldTransformer.method(:transform)) }
        end
      end

      response do
        prepare do
          record do |record, schema_class, state|
            RecordValidator.validate!(record, schema_class)
            RecordLoader.load(record, schema_class, state.request)
          end

          collection do |collection, schema_class, state|
            CollectionLoader.load(collection, schema_class, state)
          end
        end

        render do
          record do |data, schema_class, state|
            {
              schema_class.root_key.singular => data,
              meta: state.meta.presence,
            }.compact
          end

          collection do |result, schema_class, state|
            {
              schema_class.root_key.plural => result[:data],
              pagination: result[:metadata][:pagination],
              meta: state.meta.presence,
            }.compact
          end

          error do |issues, layer, _state|
            {
              layer:,
              issues: issues.map(&:to_h),
            }
          end
        end
      end
    end
  end
end
