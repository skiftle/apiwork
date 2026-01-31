# frozen_string_literal: true

module Apiwork
  module API
    class Structure
      attr_reader :namespaces,
                  :path

      def initialize(path)
        @path = path
        @namespaces = extract_namespaces(path)
        @resources = {}

        @resource_stack = []
        @current_options = nil
        @in_member_block = false
        @in_collection_block = false
        @concerns = {}
      end

      def locale_key
        @locale_key ||= path.delete_prefix('/')
      end

      def has_resources?
        @resources.any?
      end

      def has_index_actions?
        @resources.values.any?(&:has_index?)
      end

      def representation_classes
        @representation_classes ||= collect_all_representation_classes
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

      def find_resource_for_path(path_parts)
        current = nil
        path_parts.each do |part|
          next if part.match?(/\A\d+\z/)

          name = part.tr('-', '_').to_sym
          target = current ? current.resources : @resources
          found = target[name] || target[name.to_s.singularize.to_sym]
          break unless found

          current = found
        end
        current
      end

      def each_resource(&block)
        @resources.each_value do |resource|
          yield resource
          resource.each_resource(&block)
        end
      end

      def resources(
        name = nil,
        concerns: nil,
        constraints: nil,
        contract: nil,
        controller: nil,
        defaults: nil,
        except: nil,
        only: nil,
        param: nil,
        path: nil,
        &block
      )
        return @resources if name.nil?

        options = {
          constraints:,
          contract:,
          controller:,
          defaults:,
          except:,
          only:,
          param:,
          path:,
        }.compact
        build_resource(name, options:, singular: false)

        @resource_stack.push(name)

        concerns(*concerns) if concerns
        instance_eval(&block) if block

        @resource_stack.pop
      end

      def resource(
        name,
        concerns: nil,
        constraints: nil,
        contract: nil,
        controller: nil,
        defaults: nil,
        except: nil,
        only: nil,
        param: nil,
        path: nil,
        &block
      )
        options = {
          constraints:,
          contract:,
          controller:,
          defaults:,
          except:,
          only:,
          param:,
          path:,
        }.compact
        build_resource(name, options:, singular: true)

        @resource_stack.push(name)

        concerns(*concerns) if concerns
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

      def patch(actions, on: nil)
        capture_actions(actions, on:, method: :patch)
      end

      def get(actions, on: nil)
        capture_actions(actions, on:, method: :get)
      end

      def post(actions, on: nil)
        capture_actions(actions, on:, method: :post)
      end

      def put(actions, on: nil)
        capture_actions(actions, on:, method: :put)
      end

      def delete(actions, on: nil)
        capture_actions(actions, on:, method: :delete)
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

        path.split('/').reject(&:empty?).map { |segment| segment.tr('-', '_').to_sym }
      end

      def collect_all_representation_classes
        representation_classes = []
        each_resource do |resource|
          representation_class = resource.representation_class
          representation_classes << representation_class if representation_class
        end
        representation_classes
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

      def build_resource(name, options:, singular:)
        merged = merged_options(options)

        parent_name = @resource_stack.last
        parent_resource = parent_name ? find_resource(parent_name) : nil

        contract = merged.delete(:contract)

        resource = Resource.new(
          name:,
          singular:,
          contract_class_name: contract ? contract_path_to_class_name(contract) : infer_contract_class_name(name),
          parent: parent_name,
          **merged,
        )

        if parent_resource
          parent_resource.add_resource(resource)
        else
          add_resource(resource)
        end
      end

      def capture_actions(actions, method:, on:)
        Array(actions).each do |action|
          capture_action(action, method:, on: on)
        end
      end

      def capture_action(action, method:, on:)
        resource_name = @resource_stack.last
        return unless resource_name

        resource = find_resource(resource_name)
        return unless resource

        if on && [:member, :collection].exclude?(on)
          raise ConfigurationError,
                ":on option must be either :member or :collection, got #{on.inspect}"
        end

        action_type = if @in_member_block || on == :member
                        :member
                      elsif @in_collection_block || on == :collection
                        :collection
                      end

        if action_type
          resource.add_action(action, method:, type: action_type)
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
        [*@namespaces.map { |namespace| namespace.to_s.camelize }, "#{name.to_s.singularize.camelize}Contract"].join('::')
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
