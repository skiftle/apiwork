# frozen_string_literal: true

module Apiwork
  module API
    class Base
      extend Info      # Adds: info
      extend Routing   # Adds: resources, resource, concern, with_options

      class << self
        attr_reader :metadata, :recorder, :mount_path, :namespaces_parts, :specs

        def mount(path)
          @mount_path = path
          @specs = {}

          # Parse path to namespaces array
          @namespaces_parts = path == '/' ? [:root] : path.split('/').reject(&:empty?).map(&:to_sym)

          # Create metadata with path as source
          @metadata = Metadata.new(path)
          @recorder = Recorder.new(@metadata, @namespaces_parts)

          # Register in Registry
          Registry.register(self)

          # Register core descriptors for this API (idempotent - allows re-registration on Rails reload)
          Contract::Descriptor::Core.register_core_descriptors(self)

          # Initialize configuration hash
          @configuration = {}
        end

        def spec(type, path: nil)
          # Validate that type is registered
          unless Generator::Registry.registered?(type)
            available = Generator::Registry.all.join(', ')
            raise ConfigurationError,
                  "Unknown spec generator: :#{type}. " \
                  "Available generators: #{available}"
          end

          # Initialize specs hash if needed
          @specs ||= {}

          # Default path if not specified
          path ||= "/.spec/#{type}"

          # Add to specs hash
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

        def controller_namespace
          metadata.namespaces_string
        end

        def descriptors(&block)
          return unless block

          builder = Contract::Descriptor::Builder.new(api_class: self, scope: nil)
          builder.instance_eval(&block)
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
          # Build resources first - this creates contract classes and registers types/enums
          resources = {}
          metadata.resources.each do |resource_name, resource_metadata|
            resources[resource_name] = serialize_resource(resource_name, resource_metadata)
          end

          # Now collect all types and enums (after contract classes have been created)
          result = {
            path: mount_path,
            info: serialize_info,
            types: types,
            enums: enums,
            resources: resources
          }

          # Add global error codes at root level (always present, empty array if not defined)
          result[:error_codes] = metadata.error_codes || []

          result
        end

        # Serialize info metadata
        def serialize_info
          result = {}

          if metadata.info
            result[:title] = metadata.info[:title]
            result[:version] = metadata.info[:version]
            result[:description] = metadata.info[:description]
          end

          result
        end

        # All types from Descriptor::Registry
        # Returns all global types + all local types from all contracts in a single hash
        def types
          Contract::Descriptor::Registry.types(self)
        end

        # All enums from Descriptor::Registry
        # Returns all global enums + all local enums from all scopes in a single hash
        def enums
          Contract::Descriptor::Registry.enums(self)
        end

        # Serialize a single resource with all its actions and metadata
        def serialize_resource(resource_name, resource_metadata, parent_path: nil, parent_resource_name: nil)
          resource_path = build_resource_path(resource_name, resource_metadata, parent_path,
                                              parent_resource_name: parent_resource_name)

          # Extract metadata fields
          meta = resource_metadata[:metadata] || {}

          result = {
            path: resource_path, # Resource-level relative path
            summary: meta[:summary],
            description: meta[:description],
            tags: meta[:tags],
            actions: {}
          }

          # Get contract class for this resource
          # Try explicit contract first, fall back to schema-based contract
          contract_class = resolve_contract_class(resource_metadata) ||
                           schema_based_contract_class(resource_metadata)

          # Serialize CRUD actions
          if resource_metadata[:actions]&.any?
            resource_metadata[:actions].each do |action_name, action_data|
              path = build_action_path(action_name, action_name.to_sym)
              add_action_with_contract(result[:actions], action_name, action_data[:method], path, contract_class,
                                       metadata: action_data[:metadata])
            end
          end

          # Serialize member actions
          if resource_metadata[:members]&.any?
            resource_metadata[:members].each do |action_name, action_metadata|
              path = build_action_path(action_name, :member)
              add_action_with_contract(result[:actions], action_name, action_metadata[:method], path, contract_class,
                                       metadata: action_metadata[:metadata])
            end
          end

          # Serialize collection actions
          if resource_metadata[:collections]&.any?
            resource_metadata[:collections].each do |action_name, action_metadata|
              path = build_action_path(action_name, :collection)
              add_action_with_contract(result[:actions], action_name, action_metadata[:method], path, contract_class,
                                       metadata: action_metadata[:metadata])
            end
          end

          # Serialize nested resources
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

        # Build relative path for any action type
        # Returns only the action-specific segment with generic :id
        # index/create: "/"
        # show/update/destroy: "/:id"
        # member: "/:id/action_name"
        # collection: "/action_name"
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

        # Add action with method, path, and contract input/output
        def add_action_with_contract(actions, name, method, path, contract_class, metadata: {})
          # Flatten metadata fields directly onto action
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

        # Build relative path for a resource
        # Returns only the local segment, not the full absolute path
        # Top-level: "posts"
        # Nested: ":post_id/comments"
        def build_resource_path(resource_name, resource_metadata, parent_path, parent_resource_name: nil)
          resource_segment = if resource_metadata[:singular]
                               resource_name.to_s.singularize
                             else
                               resource_name.to_s
                             end

          if parent_path
            # Nested: use parent resource name for ID parameter
            parent_id_param = ":#{parent_resource_name.to_s.singularize}_id"
            "#{parent_id_param}/#{resource_segment}"
          else
            # Top-level: just the resource segment
            resource_segment
          end
        end

        # Resolve contract class from resource metadata
        # Only returns explicit contract classes (not schema-based)
        def resolve_contract_class(resource_metadata)
          return nil unless resource_metadata[:contract_class_name]

          # Try to constantize the contract class name
          klass = resource_metadata[:contract_class_name].constantize

          # Validate that it's actually a Contract class
          klass < Contract::Base ? klass : nil
        rescue NameError
          # Contract class doesn't exist
          nil
        end

        # Get or create schema-based contract class for a resource
        # Uses SchemaRegistry for consistent contract instances
        def schema_based_contract_class(resource_metadata)
          schema_class = resource_metadata[:schema_class]
          schema_class&.contract
        end
      end
    end
  end
end
