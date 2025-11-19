# frozen_string_literal: true

module Apiwork
  module API
    # Info DSL for API classes
    #
    # Provides: info
    module Info
      def info(&block)
        builder = Info::Builder.new(level: :api)
        builder.instance_eval(&block)
        @metadata.info = builder.info
      end
    end
  end
end
