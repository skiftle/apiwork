# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      class << self
        def options
          @options ||= {}
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@options, options.dup)
        end

        def option(name, type:, default:, enum: nil)
          options[name] = Option.new(name, type: type, default: default, enum: enum)
        end
      end

      def build_global_descriptors(builder, schema_data)
        raise NotImplementedError
      end

      def build_contract(contract_class, schema_class, actions:)
        raise NotImplementedError
      end

      def render_collection(collection, schema_class, action_data)
        raise NotImplementedError
      end

      def render_record(record, schema_class, action_data)
        raise NotImplementedError
      end

      def render_error(issues, action_data)
        raise NotImplementedError
      end

      def transform_request(hash, schema_class)
        hash
      end

      def transform_response(hash, schema_class)
        hash
      end
    end
  end
end
