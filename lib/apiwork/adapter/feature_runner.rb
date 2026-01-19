# frozen_string_literal: true

module Apiwork
  module Adapter
    class FeatureRunner
      def initialize(features)
        @features = features
      end

      def run(data, state)
        collection = data[:data]
        applicable = @features.select { |f| f.applies?(state.action, collection) }

        return [data, {}] if applicable.empty?

        params_map = extract_all_params(applicable, state)
        all_includes = collect_includes(applicable, params_map, state.schema_class)
        preloaded = preload_associations(collection, all_includes)

        context = build_context(state)
        result = run_pipeline(applicable, preloaded, params_map, context)
        metadata = collect_metadata(applicable, result)

        [result, metadata]
      end

      private

      def extract_all_params(features, state)
        features.index_with do |feature|
          feature.extract(state.request, state.schema_class)
        end
      end

      def collect_includes(features, params_map, schema_class)
        features.flat_map do |feature|
          feature.includes(params_map[feature], schema_class)
        end.uniq
      end

      def preload_associations(collection, includes)
        return collection if includes.empty?
        return collection unless collection.is_a?(ActiveRecord::Relation)

        collection.includes(*includes)
      end

      def run_pipeline(features, collection, params_map, context)
        features.reduce({ data: collection }) do |current, feature|
          feature.apply(current, params_map[feature], context)
        end
      end

      def collect_metadata(features, result)
        features.each_with_object({}) do |feature, meta|
          meta.merge!(feature.metadata(result))
        end
      end

      def build_context(state)
        FeatureContext.new(
          action: state.action,
          schema_class: state.schema_class,
          user_context: state.context,
        )
      end
    end
  end
end
