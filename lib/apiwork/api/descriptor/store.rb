# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module API
    module Descriptor
      class Store
        class << self
          def register(name, payload, scope: nil, metadata: {}, api_class: nil)
            store = storage(api_class)
            scoped_name_value = scope ? scoped_name(scope, name) : name

            store[scoped_name_value] = {
              name: name,
              scoped_name: scoped_name_value,
              scope: scope,
              payload: payload
            }.merge(metadata)
          end

          def resolve(name, scope: nil, api_class: nil)
            store = storage(api_class)

            if scope
              scoped_name_value = scoped_name(scope, name)
              return resolved_value(store[scoped_name_value]) if store.key?(scoped_name_value)
            end

            return resolved_value(store[name]) if store.key?(name)

            nil
          end

          def scoped_name(scope, name)
            return name unless scope

            prefix = scope.respond_to?(:scope_prefix) ? scope.scope_prefix : nil
            return name unless prefix

            return prefix.to_sym if name.nil? || name.to_s.empty?

            return name.to_sym if name.to_s == prefix

            :"#{prefix}_#{name}"
          end

          def clear!
            @storage = Concurrent::Map.new
          end

          def serialize(api)
            raise NotImplementedError, 'Subclasses must implement serialize'
          end

          protected

          def resolved_value(metadata)
            raise NotImplementedError, 'Subclasses must implement resolved_value'
          end

          def storage_name
            raise NotImplementedError, 'Subclasses must implement storage_name'
          end

          def storage(api_class)
            @storage ||= Concurrent::Map.new
            api_key = api_class.respond_to?(:mount_path) ? api_class.mount_path : api_class
            @storage.fetch_or_store(api_key) { Concurrent::Map.new }
          end
        end
      end
    end
  end
end
