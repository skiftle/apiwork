# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Runner
        class << self
          def run(capabilities, data:, representation_class:, request:, wrapper_type:)
            new(capabilities, wrapper_type:).run(data, representation_class, request)
          end
        end

        def initialize(capabilities, wrapper_type:)
          @capabilities = capabilities
          @wrapper_type = wrapper_type
        end

        def run(data, representation_class, request)
          metadata = {}
          serialize_options = {}
          includes = []

          result_data = @capabilities.reduce(data) do |current, capability|
            result = capability.apply(current, representation_class, request, wrapper_type: @wrapper_type)
            next current unless result

            metadata.merge!(result.metadata) if result.metadata
            serialize_options.merge!(result.serialize_options || {})
            includes << result.includes if result.includes.present?
            result.data || current
          end

          includes.concat(representation_class.preloads)
          preloaded = preload_associations(result_data, includes.flatten.compact)

          [preloaded, metadata, serialize_options]
        end

        private

        def preload_associations(data, includes)
          return data if includes.blank?

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
