# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
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

        def resolve(name, contract_class: nil, api_class: nil, scope: nil, visited_contracts: Set.new)
          contract = scope&.contract_class || contract_class

          raise ConfigurationError, "Circular import detected while resolving :#{name}" if contract && visited_contracts.include?(contract)

          visited_contracts = visited_contracts.dup.add(contract) if contract

          store = storage(api_class)

          if contract.respond_to?(:imports) && contract.imports.key?(name)
            imported_contract = contract.imports[name]
            result = resolve(
              name,
              contract_class: imported_contract,
              api_class: api_class,
              scope: nil,
              visited_contracts: visited_contracts
            )
            return result if result
          end

          if contract
            scoped_name_value = scoped_name(contract, name)
            return resolved_value(store[scoped_name_value]) if store.key?(scoped_name_value)
          end

          if contract.respond_to?(:imports)
            contract.imports.each do |import_alias, imported_contract|
              prefix = "#{import_alias}_"
              next unless name.to_s.start_with?(prefix)

              imported_type_name = name.to_s.sub(prefix, '').to_sym
              result = resolve(
                imported_type_name,
                contract_class: imported_contract,
                api_class: api_class,
                scope: nil,
                visited_contracts: visited_contracts
              )
              return result if result
            end
          end

          return resolved_value(store[name]) if store.key?(name)

          nil
        end

        def scoped_name(scope, name)
          return name unless scope

          contract_class = scope.is_a?(Class) ? scope : scope.contract_class

          contract_prefix = scope_prefix(contract_class)

          return name unless contract_prefix

          return contract_prefix.to_sym if name.nil? || name.to_s.empty?

          return name.to_sym if name.to_s == contract_prefix

          :"#{contract_prefix}_#{name}"
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

        def scope_prefix(contract_class)
          return contract_class._identifier if contract_class.respond_to?(:_identifier) && contract_class._identifier

          return contract_class.schema_class.root_key.singular if contract_class.respond_to?(:schema_class) && contract_class.schema_class

          return nil unless contract_class.name

          contract_class.name
                        .demodulize
                        .underscore
                        .gsub(/_(contract|schema)$/, '')
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
