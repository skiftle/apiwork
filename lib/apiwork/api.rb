# frozen_string_literal: true

module Apiwork
  module API
    def self.draw(path, &block)
      return unless block

      Class.new(Base).tap do |klass|
        klass.configure_from_path(path)
        klass.class_eval(&block)
      end
    end

    def self.find(path)
      Registry.find(path)
    end

    def self.all
      Registry.all
    end
  end
end
