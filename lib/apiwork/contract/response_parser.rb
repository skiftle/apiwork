# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseParser
      attr_reader :action_name,
                  :contract_class

      class << self
        def parse(contract_class, action_name, response)
          new(contract_class, action_name).parse(response)
        end
      end

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name.to_sym
      end

      def parse(response)
        return Result.new(response:) unless body_shape&.params&.any?

        validated = body_shape.validate(response.body)
        Result.new(issues: validated.issues, response: Response.new(body: validated.params))
      end

      private

      def action
        @action ||= contract_class.action_for(action_name)
      end

      def body_shape
        action&.response&.body
      end
    end
  end
end
