# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Base class for API definitions.
    #
    # Created via {API.define}. Configure resources, types, enums,
    # adapters, and exports. Each API is mounted at a unique path.
    #
    # @example Define an API
    #   Apiwork::API.define '/api/v1' do
    #     key_format :camel
    #
    #     resources :invoices do
    #       resources :items
    #     end
    #   end
    class Base
      class << self
        attr_reader :enum_registry,
                    :export_configs,
                    :representation_registry,
                    :structure,
                    :type_registry

        # @api public
        # The API mount path.
        #
        # @return [String]
        #
        # @example
        #   api_class.path  # => "/api/v1"
        attr_reader :path

        # @api public
        # The key format used for request/response transformation.
        #
        # @param format [Symbol] :keep, :camel, :underscore, or :kebab
        # @return [Symbol]
        #
        # @example
        #   key_format :camel
        #   api_class.key_format  # => :camel
        def key_format(format = nil)
          return @key_format if format.nil?

          valid = %i[keep camel underscore kebab]
          raise ConfigurationError, "key_format must be one of #{valid}" unless valid.include?(format)

          @key_format = format
        end

        # @api public
        # The path format used for URL path segments.
        #
        # @param format [Symbol] :keep, :kebab, :camel, or :underscore
        # @return [Symbol]
        #
        # @example
        #   path_format :kebab
        #   api_class.path_format  # => :kebab
        def path_format(format = nil)
          return @path_format if format.nil?

          valid = %i[keep kebab camel underscore]
          raise ConfigurationError, "path_format must be one of #{valid}" unless valid.include?(format)

          @path_format = format
        end

        # @api public
        # Enables an export for this API.
        #
        # Exports generate client code and documentation from your contracts.
        # Available exports: :openapi, :typescript, :zod.
        #
        # @param name [Symbol] export name to enable
        # @yield optional configuration block
        # @see Export::Base
        #
        # @example Enable OpenAPI export
        #   Apiwork::API.define '/api/v1' do
        #     export :openapi
        #   end
        #
        # @example With endpoint config
        #   export :typescript do
        #     endpoint do
        #       mode :always
        #       path '/types.ts'
        #     end
        #   end
        def export(name, &block)
          unless Export.exists?(name)
            available = Export.keys.join(', ')
            raise ConfigurationError,
                  "Unknown export: :#{name}. " \
                  "Available: #{available}"
          end

          unless @export_configs[name]
            export_class = Export.find!(name)

            options = Configurable.define(extends: export_class) do
              option :endpoint, type: :hash do
                option :mode, default: :auto, enum: %i[auto always never], type: :symbol
                option :path, type: :string
              end
            end

            @export_configs[name] = Configuration.new(options)
          end

          @export_configs[name].instance_eval(&block) if block
        end

        # @api public
        # The adapter.
        #
        # Defaults to `:standard` if no name is given.
        #
        # @param name [Symbol] adapter name
        # @yield optional configuration block
        # @return [Adapter::Base]
        # @see Adapter::Base
        #
        # @example Configure default adapter
        #   adapter do
        #     pagination do
        #       default_size 25
        #     end
        #   end
        #
        # @example Custom adapter
        #   adapter :custom
        #
        # @example Custom adapter with configuration
        #   adapter :custom do
        #     pagination do
        #       default_size 25
        #     end
        #   end
        #
        # @example Getting
        #   api_class.adapter  # => #<Apiwork::Adapter::Standard:...>
        def adapter(name = nil, &block)
          @adapter_name = name if name.is_a?(Symbol)

          if block
            adapter_config.instance_eval(&block)
            return
          end

          @adapter ||= adapter_class.new
        end

        def adapter_class
          Adapter.find!(@adapter_name || :standard)
        end

        # @api public
        # The adapter configuration for this API.
        #
        # @return [Configuration]
        # @see Adapter::Base
        #
        # @example
        #   api_class.adapter_config.pagination.default_size
        def adapter_config
          @adapter_config ||= Configuration.new(adapter_class)
        end

        # @api public
        # Defines a reusable object type (object shape).
        #
        # Object types can be referenced by name in `param` definitions.
        # Scoped types are namespaced to a contract class.
        #
        # @param name [Symbol] type name for referencing
        # @param scope [Class] a {Contract::Base} subclass for scoping (nil for global)
        # @param description [String] documentation description
        # @param example [Object] example value for docs
        # @param format [String] format hint for docs
        # @param deprecated [Boolean] mark as deprecated
        # @param representation_class [Class] a {Representation::Base} subclass for type inference
        # @see API::Object
        #
        # @example Define a reusable type
        #   object :item do
        #     string :description
        #     decimal :amount
        #   end
        #
        # @example Reference in contract
        #   array :items do
        #     reference :item
        #   end
        def object(
          name,
          scope: nil,
          description: nil,
          example: nil,
          format: nil,
          deprecated: false,
          representation_class: nil,
          &block
        )
          type_registry.register(
            name,
            deprecated:,
            description:,
            example:,
            format:,
            representation_class:,
            scope:,
            kind: :object,
            &block
          )
        end

        # @api public
        # Defines a reusable enumeration type.
        #
        # Enums can be referenced by name in `param` definitions using
        # the `enum:` option.
        #
        # @param name [Symbol] enum name for referencing
        # @param values [Array<String>] allowed values
        # @param scope [Class] a {Contract::Base} subclass for scoping (nil for global)
        # @param description [String] documentation description
        # @param example [String] example value for docs
        # @param deprecated [Boolean] mark as deprecated
        # @see Contract::Base
        #
        # @example
        #   enum :status, values: %w[draft sent paid]
        #
        # @example Reference in contract
        #   string :status, enum: :status
        def enum(
          name,
          values: nil,
          scope: nil,
          description: nil,
          example: nil,
          deprecated: false
        )
          raise ArgumentError, 'Values must be an array' if values && !values.is_a?(Array)

          enum_registry.register(
            name,
            values,
            deprecated:,
            description:,
            example:,
            scope:,
          )
        end

        # @api public
        # Defines a discriminated union type.
        #
        # Unions allow a field to accept one of several shapes, distinguished
        # by a discriminator field.
        #
        # @param name [Symbol] union name for referencing
        # @param scope [Class] a {Contract::Base} subclass for scoping (nil for global)
        # @param discriminator [Symbol] field name that identifies the variant
        #
        # @example
        #   union :payment_method, discriminator: :type do
        #     variant tag: 'card' do
        #       object do
        #         string :last_four
        #       end
        #     end
        #     variant tag: 'bank' do
        #       object do
        #         string :account_number
        #       end
        #     end
        #   end
        def union(
          name,
          discriminator: nil,
          scope: nil,
          description: nil,
          deprecated: false,
          &block
        )
          raise ArgumentError, 'Union requires a block' unless block_given?

          type_registry.register(
            name,
            deprecated:,
            description:,
            discriminator:,
            scope:,
            kind: :union,
            &block
          )
        end

        # @api public
        # API-wide error codes.
        #
        # Included in generated specs (OpenAPI, etc.) as possible error responses.
        #
        # @param error_code_keys [Array<Symbol>] registered error code keys
        # @return [Array<Symbol>]
        # @raise [ConfigurationError] if error code is not registered
        #
        # @example
        #   raises :unauthorized, :forbidden, :not_found
        #   api_class.raises  # => [:unauthorized, :forbidden, :not_found]
        def raises(*error_code_keys)
          return @raises if error_code_keys.empty?

          error_code_keys = error_code_keys.flatten.uniq
          error_code_keys.each do |error_code_key|
            unless error_code_key.is_a?(Symbol)
              hint = error_code_key.is_a?(Integer) ? " Use :#{ErrorCode.key_for_status(error_code_key)} instead." : ''
              raise ConfigurationError, "raises must be symbols, got #{error_code_key.class}: #{error_code_key}.#{hint}"
            end

            next if ErrorCode.exists?(error_code_key)

            raise ConfigurationError,
                  "Unknown error code :#{error_code_key}. Register it with: " \
                  "Apiwork::ErrorCode.register :#{error_code_key}, status: <status>"
          end
          @raises = error_code_keys
        end

        # @api public
        # API info.
        #
        # @yield block evaluated in {Info} context
        # @return [Info, nil]
        # @see API::Info
        #
        # @example
        #   info do
        #     title 'My API'
        #     version '1.0.0'
        #   end
        #   api_class.info.title  # => "My API"
        def info(&block)
          return @info unless block

          @info = Info.new
          @info.instance_eval(&block)
        end

        # @api public
        # Defines a RESTful resource with standard CRUD actions.
        #
        # This is the main method for declaring API endpoints. Creates
        # routes for index, show, create, update, destroy actions.
        # Nested resources and custom actions can be defined in the block.
        #
        # @param name [Symbol] resource name (plural)
        # @param concerns [Array<Symbol>] concerns to include
        # @param constraints [Hash, Proc] route constraints (regex, lambdas)
        # @param contract [String] custom contract path
        # @param controller [String] custom controller path
        # @param defaults [Hash] default parameters for routes
        # @param except [Array<Symbol>] exclude specific CRUD actions
        # @param only [Array<Symbol>] limit to specific CRUD actions
        # @param param [Symbol] custom parameter name for ID
        # @param path [String] custom URL path segment
        # @yield block for nested resources and custom actions
        # @see Contract::Base
        #
        # @example Basic resource
        #   Apiwork::API.define '/api/v1' do
        #     resources :invoices
        #   end
        #
        # @example With options and nested resources
        #   resources :invoices, only: [:index, :show] do
        #     member { post :archive }
        #     resources :items
        #   end
        def resources(
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
          @structure.resources(
            name,
            concerns:,
            constraints:,
            contract:,
            controller:,
            defaults:,
            except:,
            only:,
            param:,
            path:,
            &block
          )
        end

        # @api public
        # Defines a singular resource (no index action, no :id in URL).
        #
        # Useful for resources where only one instance exists,
        # like user profile or application settings.
        #
        # @param name [Symbol] resource name (singular)
        # @param concerns [Array<Symbol>] concerns to include
        # @param constraints [Hash, Proc] route constraints (regex, lambdas)
        # @param contract [String] custom contract path
        # @param controller [String] custom controller path
        # @param defaults [Hash] default parameters for routes
        # @param except [Array<Symbol>] exclude specific CRUD actions
        # @param only [Array<Symbol>] limit to specific CRUD actions
        # @param param [Symbol] custom parameter name for ID
        # @param path [String] custom URL path segment
        # @yield block for nested resources and custom actions
        # @see Contract::Base
        #
        # @example
        #   Apiwork::API.define '/api/v1' do
        #     resource :profile
        #     # Routes: GET /profile, PATCH /profile (no index, no :id)
        #   end
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
          @structure.resource(
            name,
            concerns:,
            constraints:,
            contract:,
            controller:,
            defaults:,
            except:,
            only:,
            param:,
            path:,
            &block
          )
        end

        # @api public
        # Defines a reusable concern for resources.
        #
        # Concerns are reusable blocks of resource configuration that can
        # be included in multiple resources via the `concerns` option.
        #
        # @param name [Symbol] concern name
        # @yield block defining shared actions/configuration
        #
        # @example Define and use a concern
        #   Apiwork::API.define '/api/v1' do
        #     concern :archivable do
        #       member do
        #         post :archive
        #         post :unarchive
        #       end
        #     end
        #
        #     resources :posts, concerns: [:archivable]
        #     resources :comments, concerns: [:archivable]
        #   end
        def concern(name, &block)
          @structure.concern(name, &block)
        end

        # @api public
        # Applies options to all nested resource definitions.
        #
        # Useful for applying common configuration to a group of resources.
        # Accepts the same options as {#resources}: only, except, defaults,
        # constraints, controller, param, path.
        #
        # @param options [Hash] options to apply to nested resources
        # @yield block containing resource definitions
        #
        # @example Read-only resources
        #   Apiwork::API.define '/api/v1' do
        #     with_options only: [:index, :show] do
        #       resources :reports
        #       resources :analytics
        #     end
        #   end
        def with_options(options = {}, &block)
          @structure.with_options(options, &block)
        end

        def mount(path)
          @path = path
          @info = nil
          @raises = []
          @export_configs = {}
          @adapter_config = nil
          @structure = Structure.new(path)
          @type_registry = TypeRegistry.new
          @enum_registry = EnumRegistry.new
          @representation_registry = RepresentationRegistry.new
          @built_contracts = Set.new
          @key_format = :keep
          @path_format = :keep
          @introspect_cache = {}
          @introspect_contract_cache = {}

          Registry.register(self)
        end

        def translate(*segments, default: nil)
          key = :"apiwork.apis.#{structure.locale_key}.#{segments.join('.')}"
          I18n.translate(key, default:)
        end

        def transform_path_segment(segment)
          case @path_format
          when :kebab
            segment.to_s.dasherize
          when :camel
            segment.to_s.camelize(:lower)
          else
            segment.to_s
          end
        end

        def normalize_request(request)
          return request if %i[camel kebab].exclude?(key_format)

          request.transform do |hash|
            hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
          end
        end

        def prepare_request(request)
          request
        end

        def prepare_response(response)
          result = adapter.apply_response_transformers(response)
          case key_format
          when :camel
            result.transform { |hash| hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym } }
          when :kebab
            result.transform { |hash| hash.deep_transform_keys { |key| key.to_s.dasherize.to_sym } }
          else
            result
          end
        end

        def type?(name, scope: nil)
          type_registry.exists?(name, scope:)
        end

        def type_definition(name, scope: nil)
          type_registry.find(name, scope:)
        end

        def enum?(name, scope: nil)
          enum_registry.exists?(name, scope:)
        end

        def enum_values(name, scope: nil)
          enum_registry.values(name, scope:)
        end

        def scoped_type_name(scope, name)
          type_registry.scoped_name(scope, name)
        end

        def scoped_enum_name(scope, name)
          enum_registry.scoped_name(scope, name)
        end

        def introspect(locale: nil)
          ensure_all_contracts_built!
          @introspect_cache[locale] ||= Introspection.api(self, locale:)
        end

        def introspect_contract(contract_class, expand:, locale:)
          ensure_all_contracts_built!
          cache_key = [contract_class, locale, expand]
          @introspect_contract_cache[cache_key] ||= Introspection.contract(contract_class, expand:, locale:)
        end

        def reset_contracts!
          @built_contracts = Set.new
          @introspect_cache = {}
          @introspect_contract_cache = {}
        end

        def ensure_contract_built!(contract_class)
          return if built_contracts.include?(contract_class)

          ensure_pre_pass_complete!

          representation_class = contract_class.representation_class
          return unless representation_class

          built_contracts.add(contract_class)

          resource = @structure.find_resource { |resource| resource.resolve_contract_class == contract_class }
          actions = resource ? build_adapter_actions(resource.actions) : {}

          adapter.register_contract(contract_class, representation_class, actions)
        end

        def ensure_pre_pass_complete!
          return if @pre_pass_complete

          mark_nested_writable_representations!
          @pre_pass_complete = true
        end

        def ensure_all_contracts_built!
          mark_nested_writable_representations!

          @structure.each_resource do |resource|
            build_contracts_for_resource(resource)
          end

          features = adapter.build_features(@structure)
          adapter.register_api(self, features)
        end

        private

        attr_reader :built_contracts

        def mark_nested_writable_representations!
          visited = Set.new
          @structure.each_resource do |resource|
            representation_class = resource.resolve_contract_class&.representation_class
            next unless representation_class

            representation_registry.register(representation_class)
            mark_writable_associations(representation_class, visited)
          end
        end

        def mark_writable_associations(representation_class, visited)
          return if visited.include?(representation_class)

          visited.add(representation_class)

          representation_class.associations.each_value do |association|
            next unless association.writable?

            target_representation = resolve_target_representation(association, representation_class)
            next unless target_representation

            representation_registry.register(target_representation)
            representation_registry.mark(target_representation, :nested_writable)
            mark_writable_associations(target_representation, visited)
          end
        end

        def resolve_target_representation(association, owner_representation)
          return association.representation_class if association.representation_class
          return nil unless owner_representation.model_class

          reflection = owner_representation.model_class.reflect_on_association(association.name)
          return nil unless reflection
          return nil if reflection.polymorphic?

          namespace = owner_representation.name.deconstantize
          "#{namespace}::#{reflection.klass.name.demodulize}Representation".safe_constantize
        end

        def build_contracts_for_resource(resource)
          contract_class = resource.resolve_contract_class
          return unless contract_class
          return if built_contracts.include?(contract_class)

          representation_class = contract_class.representation_class
          return unless representation_class

          built_contracts.add(contract_class)

          adapter.register_contract(contract_class, representation_class, build_adapter_actions(resource.actions))
        end

        def build_adapter_actions(actions)
          actions.transform_values { |action| Adapter::Action.new(action.name, action.method, action.type) }
        end
      end
    end
  end
end
