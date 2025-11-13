# frozen_string_literal: true

module Apiwork
  module API
    def self.draw(path, &block)
      return unless block

      definition_class = Class.new(Base)
      definition_class.configure_from_path(path)
      definition_class.class_eval(&block)
      definition_class
    end

    def self.find(path)
      Registry.find(path)
    end

    def self.all
      Registry.all_classes
    end
  end
end
