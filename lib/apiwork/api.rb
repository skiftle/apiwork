# frozen_string_literal: true

module Apiwork
  module API
    class << self
      # DOCUMENTATION
      def draw(path, &block)
        return unless block

        Class.new(Base).tap do |klass|
          klass.mount(path)
          klass.class_eval(&block)
          klass.build_contracts
        end
      end

      def find(path)
        Registry.find(path)
      end

      def all
        Registry.all
      end

      # DOCUMENTATION
      def introspect(path)
        find(path)&.introspect
      end

      # DOCUMENTATION
      def reset!
        # Clear cached introspection AND action definitions from all APIs before clearing registry
        # rubocop:disable Rails/FindEach
        Registry.all.each do |api_class|
          api_class.instance_variable_set(:@introspect, nil) if api_class.instance_variable_defined?(:@introspect)

          # Clear action_definitions from all contract classes
          api_class.metadata&.resources&.each_value do |resource_data|
            clear_contract_action_definitions(resource_data)
          end
        end
        # rubocop:enable Rails/FindEach

        Registry.clear!
      end

      private

      def clear_contract_action_definitions(resource_data)
        contract_class = resource_data[:contract_class]
        contract_class&.action_definitions&.clear

        # Recursively clear nested resources
        resource_data[:resources]&.each_value do |nested_resource|
          clear_contract_action_definitions(nested_resource)
        end
      end
    end
  end
end
