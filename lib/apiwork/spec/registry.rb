# frozen_string_literal: true

module Apiwork
  module Spec
    class Registry
      class << self
        def store
          @store ||= Store.new
        end

        def register(spec_class)
          raise ArgumentError, 'Spec must inherit from Apiwork::Spec::Base' unless spec_class < Base
          raise ArgumentError, "Spec #{spec_class} must define a spec_name" unless spec_class.spec_name

          store[spec_class.spec_name] = spec_class
        end

        def find(name)
          key = name.to_sym
          store.fetch(key) { raise KeyError.new("Spec :#{key} not found. Available: #{all.join(', ')}", key:, receiver: store) }
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
