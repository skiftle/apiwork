# frozen_string_literal: true

module Apiwork
  module Adapter
    class CapabilityRunner
      def initialize(capabilities)
        @capabilities = capabilities
      end

      def run(data, state)
        collection = data[:data]
        applicable = @capabilities.select { |c| c.applies?(state.action, collection) }

        return [data, {}] if applicable.empty?

        params_map = extract_all_params(applicable, state)
        all_includes = collect_includes(applicable, params_map, state.schema_class)
        preloaded = preload_associations(collection, all_includes)

        context = build_context(state)
        transformed, metadata = run_pipeline(applicable, preloaded, params_map, context)
        serialize_options = collect_serialize_options(applicable, params_map, state.schema_class)

        [{ serialize_options:, data: transformed }, metadata]
      end

      private

      def extract_all_params(capabilities, state)
        capabilities.index_with do |capability|
          capability.extract(state.request, state.schema_class)
        end
      end

      def collect_includes(capabilities, params_map, schema_class)
        capabilities.flat_map do |capability|
          capability.includes(params_map[capability], schema_class)
        end.uniq
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

      def run_pipeline(capabilities, collection, params_map, context)
        metadata = {}

        data = capabilities.reduce(collection) do |current, capability|
          capability.apply(current, metadata, params_map[capability], context)
        end

        [data, metadata]
      end

      def collect_serialize_options(capabilities, params_map, schema_class)
        capabilities.each_with_object({}) do |capability, opts|
          opts.merge!(capability.serialize_options(params_map[capability], schema_class))
        end
      end

      def build_context(state)
        CapabilityContext.new(
          action: state.action,
          schema_class: state.schema_class,
          user_context: state.context,
        )
      end
    end
  end
end
