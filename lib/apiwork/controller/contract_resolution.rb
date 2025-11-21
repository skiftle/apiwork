# frozen_string_literal: true

module Apiwork
  module Controller
    module ContractResolution
      extend ActiveSupport::Concern

      included do
        before_action :set_current_contract
      end

      private

      def set_current_contract
        @current_contract = infer_schema_contract || infer_contract_class || raise_no_contract_class_error
      end

      def current_contract
        @current_contract
      end

      def infer_schema_contract
        schema_class = infer_schema_class
        return nil unless schema_class

        schema_class.contract
      end

      def infer_schema_class
        schema_name = "#{self.class.name.sub(/Controller$/, '').singularize}Schema"
        schema_name.constantize
      rescue NameError
        nil
      end

      def infer_contract_class
        contract_name = "#{self.class.name.sub(/Controller$/, '').singularize}Contract"
        contract_name.constantize
      rescue NameError
        nil
      end

      def raise_no_contract_class_error
        schema_class_name = "#{self.class.name.sub(/Controller$/, '').singularize}Schema"
        contract_class_name = "#{self.class.name.sub(/Controller$/, '').singularize}Contract"

        raise ConfigurationError, "No schema or contract found for #{self.class.name}. " \
                                  "Expected #{schema_class_name} or #{contract_class_name} to be defined."
      end
    end
  end
end
