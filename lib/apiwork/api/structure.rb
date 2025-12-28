# frozen_string_literal: true

module Apiwork
  module API
    class Structure
      attr_reader :namespaces,
                  :path

      attr_accessor :info,
                    :raises

      def initialize(path)
        @path = path
        @namespaces = extract_namespaces(path)
        @resources = {}
        @info = nil
        @raises = []

        @resource_stack = []
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
        @concerns = {}
      end

      def locale_key
        @locale_key ||= path.delete_prefix('/')
      end

      def i18n_lookup(*segments, default: nil)
        key = :"apiwork.apis.#{locale_key}.#{segments.join('.')}"
        I18n.t(key, default:)
      end

      def has_resources?
        @resources.any?
      end

      def has_index_actions?
        @resources.values.any?(&:has_index?)
      end

      def schema_classes
        @schema_classes ||= collect_all_schema_classes
      end

      def add_resource(resource)
        @resources[resource.name] = resource
      end

      def find_resource(name = nil, &block)
        return find_resource_by_block(&block) if block
        return @resources[name] if @resources[name]

        @resources.each_value do |resource|
          found = resource.find_resource(name)
          return found if found
        end

        nil
      end

      def each_resource(&block)
        @resources.each_value do |resource|
          yield resource
          resource.each_resource(&block)
        end
      end

      def resources(name = nil, **options, &block)
        return @resources if name.nil?

        concern_names = options.delete(:concerns)

        create_resource(name, singular: false, options: options)

        @resource_stack.push(name)

        concerns(*concern_names) if concern_names
        instance_eval(&block) if block

        @resource_stack.pop
      end

      def resource(name, **options, &block)
        concern_names = options.delete(:concerns)

        create_resource(name, singular: true, options: options)

        @resource_stack.push(name)

        concerns(*concern_names) if concern_names
        instance_eval(&block) if block

        @resource_stack.pop
      end

      def with_options(options = {}, &block)
        old_options = @current_options
        @current_options = merged_options(options)

        instance_eval(&block)

        @current_options = old_options
      end

      def member(&block)
        @in_member_block = true
        instance_eval(&block)
        @in_member_block = false
      end

      def collection(&block)
        @in_collection_block = true
        instance_eval(&block)
        @in_collection_block = false
      end

      def patch(actions, **options)
        capture_actions(actions, method: :patch, options: options)
      end

      def get(actions, **options)
        capture_actions(actions, method: :get, options: options)
      end

      def post(actions, **options)
        capture_actions(actions, method: :post, options: options)
      end

      def put(actions, **options)
        capture_actions(actions, method: :put, options: options)
      end

      def delete(actions, **options)
        capture_actions(actions, method: :delete, options: options)
      end

      def concern(name, callable = nil, &block)
        callable ||= ->(structure, options) { structure.instance_exec(options, &block) }
        @concerns[name] = callable
      end

      def concerns(*names, **options)
        names.flatten.each do |name|
          callable = @concerns[name]
          raise ConfigurationError, "No concern named :#{name} was found" unless callable

          callable.call(self, options)
        end
      end

      private

      def extract_namespaces(path)
        return [] if path == '/'

        path.split('/').reject(&:empty?).map { |n| n.tr('-', '_').to_sym }
      end

      def collect_all_schema_classes
        schema_classes = []
        each_resource do |resource|
          schema_class = resource.schema_class
          schema_classes << schema_class if schema_class
        end
        schema_classes
      end

      def find_resource_by_block(&block)
        @resources.each_value do |resource|
          return resource if yield(resource)

          found = resource.find_resource(&block)
          return found if found
        end

        nil
      end

      def merged_options(options = {})
        (@current_options || {}).merge(options)
      end

      def current_resource
        return nil if @resource_stack.empty?

        find_resource(@resource_stack.last)
      end

      def create_resource(name, singular:, options:)
        merged = merged_options(options)

        parent_name = @resource_stack.last
        parent_resource = parent_name ? find_resource(parent_name) : nil

        contract = merged.delete(:contract)

        contract_class_name = if contract
                                contract_path_to_class_name(contract)
                              else
                                infer_contract_class_name(name)
                              end

        resource = Resource.new(
          name: name,
          singular: singular,
          contract_class_name: contract_class_name,
          parent: parent_name,
          **merged
        )

        if parent_resource
          parent_resource.add_resource(resource)
        else
          add_resource(resource)
        end
      end

      def capture_actions(actions, method:, options:)
        Array(actions).each do |action|
          capture_action(action, method: method, options: options)
        end
      end

      def capture_action(action, method:, options:)
        resource_name = @resource_stack.last
        return unless resource_name

        resource = find_resource(resource_name)
        return unless resource

        if options[:on] && [:member, :collection].exclude?(options[:on])
          raise ConfigurationError,
                ":on option must be either :member or :collection, got #{options[:on].inspect}"
        end

        action_type = if @in_member_block || options[:on] == :member
                        :member
                      elsif @in_collection_block || options[:on] == :collection
                        :collection
                      end

        if action_type
          resource.add_action(action, type: action_type, method: method)
        else
          raise ConfigurationError,
                "Action '#{action}' on resource '#{resource_name}' must be declared " \
                "within a member or collection block, or use the :on parameter.\n" \
                "Examples:\n" \
                "  member { #{method} :#{action} }\n" \
                "  #{method} :#{action}, on: :member\n" \
                "  collection { #{method} :#{action} }\n" \
                "  #{method} :#{action}, on: :collection"
        end
      end

      def infer_contract_class_name(name)
        contract_name = name.to_s.singularize.camelize
        [*@namespaces.map { |n| n.to_s.camelize }, "#{contract_name}Contract"].join('::')
      end

      def contract_path_to_class_name(path)
        parts = if path.start_with?('/')
                  path[1..].split('/')
                else
                  @namespaces + path.split('/')
                end

        parts = parts.map { |part| part.to_s.camelize }
        parts[-1] = parts[-1].singularize

        "#{parts.join('::')}Contract"
      end
    end
  end
end
