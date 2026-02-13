# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseParser
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
        return Result.new(response:) unless action

        shape = action.response.body
        return Result.new(response:) unless shape
        return Result.new(response:) unless shape.params.any?

        validated = shape.validate(response.body)
        Result.new(issues: validated.issues, response: Response.new(body: validated.params))
      end

      private

      def action
        @action ||= @contract_class.action_for(@action_name)
      end
    end
  end
end
