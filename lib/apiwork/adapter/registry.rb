# frozen_string_literal: true

module Apiwork
  module Adapter
    class Registry < Apiwork::Registry
      class << self
        def register(adapter_class)
          raise ArgumentError, 'Adapter must inherit from Apiwork::Adapter::Base' unless adapter_class < Base
          raise ArgumentError, "Adapter #{adapter_class} must define an adapter_name" unless adapter_class.adapter_name

          store[adapter_class.adapter_name] = adapter_class
        end
      end
    end
  end
end
