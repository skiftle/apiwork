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
          data = request.query_parameters.merge(request.request_parameters).deep_symbolize_keys

          Contract::Parser.new(current_contract, :input, action_name).perform(Transform::Case.hash(data, key_transform))
        end
      end

      private

      def validate_input
        return if action_input.valid?

        raise ContractError, action_input.issues
      end

      def key_transform
        Apiwork.configuration.deserialize_key_transform
      end
    end
  end
end
