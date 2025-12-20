# frozen_string_literal: true

module Apiwork
  module Adapter
    class Registry
      class << self
        def store
          @store ||= Store.new
        end

        def register(adapter_class)
          raise ArgumentError, 'Adapter must inherit from Apiwork::Adapter::Base' unless adapter_class < Base
          raise ArgumentError, "Adapter #{adapter_class} must define an adapter_name" unless adapter_class.adapter_name

          store[adapter_class.adapter_name] = adapter_class
        end

        def find(name)
          key = name.to_sym
          store.fetch(key) { raise KeyError.new("Adapter :#{key} not found. Available: #{all.join(', ')}", key:, receiver: store) }
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
