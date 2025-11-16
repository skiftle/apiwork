# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      included do
        before_action :validate_input
      end

      class_methods do
        def skip_validate_input!(only: nil, except: nil)
          skip_before_action :validate_input, only: only, except: except
        end
      end

      def action_input
        @action_input ||= begin
          parser = Contract::Parser.new(current_contract, :input, action_name, coerce: true)

          data = request.query_parameters.merge(request.request_parameters).deep_symbolize_keys
          data = transform_input_keys(data, key_transform)
          data = ParamsNormalizer.call(data)

          parser.perform(data)
        end
      end

      private

      def validate_input
        return if action_input.valid?

        raise ContractError, action_input.issues
      end

      def key_transform
        Configuration::Resolver.resolve(:input_key_format, contract_class: current_contract)
      end

      def transform_input_keys(hash, strategy)
        case strategy
        when :camel
          hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
        when :underscore
          hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
        else
          hash
        end
      end
    end
  end
end
