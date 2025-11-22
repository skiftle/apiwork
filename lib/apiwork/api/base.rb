# frozen_string_literal: true

module Apiwork
  module API
    class Base
      class << self
        attr_reader :metadata,
                    :mount_path,
                    :namespaces,
                    :recorder,
                    :specs

        def mount(path)
          @mount_path = path
          @specs = {}

          @namespaces = path == '/' ? [:root] : path.split('/').reject(&:empty?).map(&:to_sym)

          @metadata = Metadata.new(path)
          @recorder = Recorder.new(@metadata, @namespaces)

          Registry.register(self)

          Descriptor.register_core(self)

          @configuration = {}
        end

        def spec(type, path: nil)
          unless Generator::Registry.registered?(type)
            available = Generator::Registry.all.join(', ')
            raise ConfigurationError,
                  "Unknown spec generator: :#{type}. " \
                  "Available generators: #{available}"
          end

          @specs ||= {}

          path ||= "/.spec/#{type}"

          @specs[type] = path
        end

        def specs?
          @specs&.any?
        end

        def error_codes(*codes)
          @metadata.error_codes = codes.flatten.map(&:to_i).uniq.sort
        end

        def configure(&block)
          return unless block

          builder = Configuration::Builder.new(@configuration)
          builder.instance_eval(&block)
        end

        def configuration
          @configuration ||= {}
        end

        def type(name, description: nil, example: nil, format: nil, deprecated: false, &block)
          Descriptor.define_type(
            name,
            api_class: self,
            description: description,
            example: example,
            format: format,
            deprecated: deprecated,
            &block
          )
        end

        def enum(name, values:, description: nil, example: nil, deprecated: false)
          Descriptor.define_enum(
            name,
            values: values,
            api_class: self,
            description: description,
            example: example,
            deprecated: deprecated
          )
        end

        def union(name, &block)
          Descriptor.define_union(name, api_class: self, &block)
        end

        def info(&block)
          builder = Info::Builder.new
          builder.instance_eval(&block)
          @metadata.info = builder.info
        end

        def resources(name, **options, &block)
          @recorder.resources(name, **options, &block)
        end

        def resource(name, **options, &block)
          @recorder.resource(name, **options, &block)
        end

        def concern(name, &block)
          @recorder.concern(name, &block)
        end

        def with_options(options = {}, &block)
          @recorder.with_options(options, &block)
        end

        def introspect
          return nil unless metadata

          @introspect ||= build_introspection_result
        end

        def as_json
          introspect
        end

        private

        def build_introspection_result
          resources = {}
          metadata.resources.each do |resource_name, resource_metadata|
            resources[resource_name] = serialize_resource(resource_name, resource_metadata)
          end

          result = {
            path: mount_path,
            info: serialize_info,
            types: types,
            enums: enums,
            resources: resources
          }

          result[:error_codes] = metadata.error_codes || []

          result
        end

        def serialize_info
          result = {}

          if metadata.info
            result[:title] = metadata.info[:title]
            result[:version] = metadata.info[:version]
            result[:description] = metadata.info[:description]
          end

          result
        end

        def types
          Descriptor.types(self)
        end

        def enums
          Descriptor.enums(self)
        end

        def serialize_resource(resource_name, resource_metadata, parent_path: nil, parent_resource_name: nil)
          resource_path = build_resource_path(resource_name, resource_metadata, parent_path,
                                              parent_resource_name: parent_resource_name)

          meta = resource_metadata[:metadata] || {}

          result = {
            path: resource_path, # Resource-level relative path
            summary: meta[:summary],
            description: meta[:description],
            tags: meta[:tags],
            actions: {}
          }

          contract_class = resolve_contract_class(resource_metadata) ||
                           schema_based_contract_class(resource_metadata)

          if resource_metadata[:actions]&.any?
            resource_metadata[:actions].each do |action_name, action_data|
              path = build_action_path(action_name, action_name.to_sym)
              add_action_with_contract(result[:actions], action_name, action_data[:method], path, contract_class,
                                       metadata: action_data[:metadata])
            end
          end

          if resource_metadata[:members]&.any?
            resource_metadata[:members].each do |action_name, action_metadata|
              path = build_action_path(action_name, :member)
              add_action_with_contract(result[:actions], action_name, action_metadata[:method], path, contract_class,
                                       metadata: action_metadata[:metadata])
            end
          end

          if resource_metadata[:collections]&.any?
            resource_metadata[:collections].each do |action_name, action_metadata|
              path = build_action_path(action_name, :collection)
              add_action_with_contract(result[:actions], action_name, action_metadata[:method], path, contract_class,
                                       metadata: action_metadata[:metadata])
            end
          end

          if resource_metadata[:resources]&.any?
            result[:resources] = {}
            resource_metadata[:resources].each do |nested_name, nested_metadata|
              result[:resources][nested_name] = serialize_resource(
                nested_name,
                nested_metadata,
                parent_path: resource_path,
                parent_resource_name: resource_name
              )
            end
          end

          result
        end

        def build_action_path(action_name, action_type)
          case action_type
          when :index, :create
            '/'
          when :show, :update, :destroy
            '/:id'
          when :member
            "/:id/#{action_name}"
          when :collection
            "/#{action_name}"
          else
            '/'
          end
        end

        def add_action_with_contract(actions, name, method, path, contract_class, metadata: {})
          actions[name] = {
            method:,
            path:,
            summary: metadata[:summary],
            description: metadata[:description],
            tags: metadata[:tags],
            deprecated: metadata[:deprecated],
            operation_id: metadata[:operation_id]
          }

          return unless contract_class

          action_definition = contract_class.action_definition(name)
          return unless action_definition

          contract_json = action_definition.as_json
          actions[name][:input] = contract_json[:input] || {}
          actions[name][:output] = contract_json[:output] || {}
          actions[name][:error_codes] = contract_json[:error_codes] || []
        end

        def build_resource_path(resource_name, resource_metadata, parent_path, parent_resource_name: nil)
          resource_segment = if resource_metadata[:singular]
                               resource_name.to_s.singularize
                             else
                               resource_name.to_s
                             end

          if parent_path
            parent_id_param = ":#{parent_resource_name.to_s.singularize}_id"
            "#{parent_id_param}/#{resource_segment}"
          else
            resource_segment
          end
        end

        def resolve_contract_class(resource_metadata)
          contract_class = resource_metadata[:contract_class]
          return nil unless contract_class

          contract_class < Contract::Base ? contract_class : nil
        end

        def schema_based_contract_class(resource_metadata)
          schema_class = resource_metadata[:schema_class]
          schema_class&.contract
        end
      end
    end
  end
end
