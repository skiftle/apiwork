# frozen_string_literal: true

module Apiwork
  # @api private
  module Registrable
    extend ActiveSupport::Concern

    class_methods do
      def identifier(name = nil)
        @identifier = name.to_sym if name
        @identifier
      end
    end
  end
end
