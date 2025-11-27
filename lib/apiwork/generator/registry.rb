# frozen_string_literal: true

module Apiwork
  module Generator
    class Registry
      class << self
        def store
          @store ||= Store.new
        end

        def register(generator_class)
          raise ArgumentError, 'Generator must inherit from Apiwork::Generator::Base' unless generator_class < Base
          raise ArgumentError, "Generator #{generator_class} must define an identifier" unless generator_class.identifier

          store[generator_class.identifier] = generator_class
        end

        def find(name)
          key = name.to_sym
          store.fetch(key) { raise KeyError.new("Generator :#{key} not found. Available: #{all.join(', ')}", key:, receiver: store) }
        end

        def registered?(name)
          store.key?(name.to_sym)
        end

        def all
          store.keys
        end

        def clear!
          @store = Store.new
        end
      end
    end
  end
end
