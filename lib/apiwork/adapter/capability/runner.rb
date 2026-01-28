# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Runner
        def initialize(capabilities, document_type:)
          @capabilities = capabilities
          @document_type = document_type
        end

        def run(data, representation_class, request)
          collection = data[:data]
          return [data, {}] if @capabilities.empty?

          transformed, document, serialize_options = run_pipeline(@capabilities, collection, representation_class, request)

          [{ serialize_options:, data: transformed }, document]
        end

        private

        def run_pipeline(capabilities, collection, representation_class, request)
          document = {}
          serialize_options = {}
          includes = []

          data = capabilities.reduce(collection) do |current, capability|
            result = capability.apply(current, representation_class, request, document_type: @document_type)
            next current unless result

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
      end
    end
  end
end
