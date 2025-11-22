# frozen_string_literal: true

module Apiwork
  module Contract
    class << self
      # DOCUMENTATION
      def reset!
        SchemaRegistry.clear!
      end
    end
  end
end
