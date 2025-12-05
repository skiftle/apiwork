# frozen_string_literal: true

module Apiwork
  module API
    class << self
      # DOCUMENTATION
      def draw(path, &block)
        return unless block

        Class.new(Base).tap do |klass|
          klass.mount(path)
          klass.class_eval(&block)
        end
      end

      def find(path)
        Registry.find(path)
      end

      def all
        Registry.all
      end

      # DOCUMENTATION
      def introspect(path, locale: nil)
        find(path)&.introspect(locale:)
      end

      # DOCUMENTATION
      def reset!
        Registry.clear!
      end
    end
  end
end
