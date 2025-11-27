# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Adapter
    class Registry
      class << self
        def adapters
          @adapters ||= Concurrent::Map.new
        end

        def register(adapter_class)
          raise ArgumentError, 'Adapter must inherit from Apiwork::Adapter::Base' unless adapter_class < Base
          raise ArgumentError, "Adapter #{adapter_class} must define an identifier" unless adapter_class.identifier

          adapters[adapter_class.identifier] = adapter_class
        end

        def find(name)
          key = name.to_sym
          adapters.fetch(key) { raise KeyError.new("Adapter :#{key} not found. Available: #{all.join(', ')}", key:, receiver: adapters) }
        end

        def registered?(name)
          adapters.key?(name.to_sym)
        end

        def all
          adapters.keys
        end

        def clear!
          @adapters = Concurrent::Map.new
        end
      end
    end
  end
end
