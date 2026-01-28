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
          return [data, {}, {}] if @capabilities.empty?

          run_pipeline(@capabilities, data, representation_class, request)
        end

        private

        def run_pipeline(capabilities, collection, representation_class, request)
          metadata = {}
          serialize_options = {}
          includes = []

          data = capabilities.reduce(collection) do |current, capability|
            result = capability.apply(current, representation_class, request, document_type: @document_type)
            next current unless result

            metadata.merge!(result.metadata) if result.metadata
            serialize_options.merge!(result.serialize_options || {})
            includes.concat(result.includes || [])
            result.data
          end

          preloaded = preload_associations(data, includes.uniq)

          [preloaded, metadata, serialize_options]
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
