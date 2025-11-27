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
        # rubocop:disable Rails/FindEach
        Registry.all.each do |api_class|
          api_class.instance_variable_set(:@introspect, nil) if api_class.instance_variable_defined?(:@introspect)
          api_class.instance_variable_set(:@contracts_built_for, Set.new)

          api_class.metadata&.resources&.each_value do |resource_data|
            clear_resource_caches(resource_data)
          end
        end
        # rubocop:enable Rails/FindEach

        Registry.clear!
      end

      private

      def clear_resource_caches(resource_data)
        contract_class = resource_data[:contract_class]
        contract_class&.action_definitions&.clear

        resource_data[:schema_class] = nil
        resource_data[:contract_class] = nil

        resource_data[:resources]&.each_value do |nested_resource|
          clear_resource_caches(nested_resource)
        end
      end
    end
  end
end
