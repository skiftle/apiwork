# frozen_string_literal: true

module Apiwork
  module Schema
    class << self
      def reset!
        Resolver.clear_cache!
      end
    end
  end
end
