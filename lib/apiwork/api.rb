# frozen_string_literal: true

module Apiwork
  module API
    class << self
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

      def introspect(path)
        find(path)&.introspect
      end
    end
  end
end
