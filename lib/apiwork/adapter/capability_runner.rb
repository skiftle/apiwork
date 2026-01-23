# frozen_string_literal: true

module Apiwork
  module Adapter
    class CapabilityRunner
      def initialize(capabilities, document_type:)
        @capabilities = capabilities
        @document_type = document_type
      end

      def run(data, state)
        collection = data[:data]
        return [data, {}] if @capabilities.empty?

        context = build_context(state)
        transformed, document, serialize_options = run_pipeline(@capabilities, collection, context)

        [{ serialize_options:, data: transformed }, document]
      end

      private

      def run_pipeline(capabilities, collection, context)
        document = {}
        serialize_options = {}
        includes = []

        data = capabilities.reduce(collection) do |current, capability|
          result = capability.apply(current, context)
          document.merge!(result.document) if result.document
          serialize_options.merge!(result.serialize_options || {})
          includes.concat(result.includes || [])
          result.data
        end

        preloaded = preload_associations(data, includes.uniq)

        [preloaded, document, serialize_options]
      end

      def preload_associations(data, includes)
        return data if includes.empty?

        if data.is_a?(ActiveRecord::Relation)
          data.includes(*includes)
        elsif data.is_a?(ActiveRecord::Base)
          ActiveRecord::Associations::Preloader.new(associations: includes, records: [data]).call
          data
        else
          data
        end
      end

      def build_context(state)
        CapabilityContext.new(
          action: state.action,
          document_type: @document_type,
          request: state.request,
          schema_class: state.schema_class,
          user_context: state.context,
        )
      end
    end
  end
end
