# frozen_string_literal: true

module Apiwork
  module Spec
    module Options
      module_function

      def build(**options)
        options.compact
      end
    end
  end
end
