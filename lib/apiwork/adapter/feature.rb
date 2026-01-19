# frozen_string_literal: true

module Apiwork
  module Adapter
    class Feature
      include Configurable

      class << self
        def feature_name(value = nil)
          @feature_name = value.to_sym if value
          @feature_name
        end
      end

      attr_reader :config

      def initialize(config = {})
        merged = self.class.default_options.deep_merge(config)
        @config = Configuration.new(self.class, merged)
      end

      def api(registrar, capabilities); end

      def contract(registrar, schema_class); end

      def apply(data, state)
        data
      end

      def metadata(result, state)
        {}
      end
    end
  end
end
