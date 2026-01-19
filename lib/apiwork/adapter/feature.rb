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

        def applies_to(*action_types)
          @applies_to = action_types.map(&:to_sym)
        end

        def applies_to_actions
          @applies_to || []
        end

        def input(type)
          @input_type = type
        end

        def input_type
          @input_type || :any
        end
      end

      attr_reader :config

      def initialize(config = {})
        merged = self.class.default_options.deep_merge(config)
        @config = Configuration.new(self.class, merged)
      end

      def api(registrar, capabilities); end

      def contract(registrar, schema_class); end

      def extract(request, schema_class)
        {}
      end

      def includes(params, schema_class)
        []
      end

      def apply(data, params, context)
        data
      end

      def metadata(result)
        {}
      end

      def applies?(action, data)
        return true if self.class.applies_to_actions.empty?
        return false unless self.class.applies_to_actions.include?(action.name)

        valid_input?(data)
      end

      private

      def valid_input?(data)
        case self.class.input_type
        when :collection
          data.is_a?(ActiveRecord::Relation)
        when :record
          data.is_a?(ActiveRecord::Base)
        else
          true
        end
      end
    end
  end
end
