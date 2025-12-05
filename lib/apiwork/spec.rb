# frozen_string_literal: true

module Apiwork
  module Spec
    class << self
      delegate :register, :find, to: Registry

      def generate(identifier, api_path, **options)
        find(identifier)&.generate(api_path, **options)
      end

      def reset!
        Registry.clear!
      end
    end
  end
end
