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
    #       resources :line_items
    #     end
    #   end
    class Base
      class << self
        attr_reader :adapter_config,
                    :enum_registry,
                    :export_configs,
                    :exports,
                    :path,
                    :structure,
                    :type_registry

        # @api public
        # Sets the key format for request/response transformation.
        #
        # Controls how JSON keys are transformed between client and server.
        # Useful for JavaScript clients that prefer camelCase.
        #
        # @param format [Symbol] :keep (no transform), :camel (to/from camelCase), :underscore
        # @return [Symbol] the current key format
        #
        # @example camelCase for JavaScript clients
        #   Apiwork::API.define '/api/v1' do
        #     key_format :camel
        #     # { firstName: 'John' } ↔ { first_name: 'John' }
        #   end
        def key_format(format = nil)
          return @key_format if format.nil?

          valid = %i[keep camel underscore kebab]
          raise ConfigurationError, "key_format must be one of #{valid}" unless valid.include?(format)

          @key_format = format
        end

        # @api public
        # Sets the path format for URL path segments.
        #
        # Controls how resource names are transformed into URL paths.
        # Does not affect payload keys or internal identifiers.
        #
        # @param format [Symbol] :keep (no transform), :kebab (kebab-case), :camel (camelCase)
        # @return [Symbol] the current path format
        #
        # @example kebab-case paths for REST conventions
        #   Apiwork::API.define '/api/v1' do
        #     path_format :kebab
        #     resources :recurring_invoices
        #     # Routes: GET /api/v1/recurring-invoices
        #   end
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
        # @example With custom path
        #   export :typescript do
        #     path '/types.ts'
        #   end
        def export(name, &block)
          unless Export.registered?(name)
            available = Export.all.join(', ')
            raise ConfigurationError,
                  "Unknown export: :#{name}. " \
                  "Available: #{available}"
          end

          @exports.add(name)
          @export_configs[name] ||= {}
          @export_configs[name][:path] ||= "/.#{name}"

          return unless block

          export_class = Export.find(name)
          builder = Configuration::Builder.new(export_class, @export_configs[name])
          builder.instance_eval(&block)
        end

        # @api public
        # Configures the adapter for this API.
        #
        # Adapters control serialization, pagination, filtering, and response
        # formatting. Without arguments, uses the built-in :apiwork adapter.
        #
        # @param name [Symbol] adapter name (:apiwork, or a registered custom adapter)
        # @yield optional configuration block
        # @see Adapter::Base
        #
        # @example Use a custom adapter
        #   Apiwork::API.define '/api/v1' do
        #     adapter :my_adapter
        #   end
        #
        # @example Configure pagination
        #   Apiwork::API.define '/api/v1' do
        #     adapter do
        #       pagination do
        #         strategy :offset
        #         default_size 25
        #         max_size 100
        #       end
        #     end
        #   end
        def adapter(name = nil, &block)
          @adapter_name = name if name.is_a?(Symbol)

          if block
            adapter_class = Adapter.find(@adapter_name || :standard)
            builder = Configuration::Builder.new(adapter_class, @adapter_config)
            builder.instance_eval(&block)
            return
          end

          @adapter ||= Adapter.find(@adapter_name || :standard).new
        end

        # @api public
        # Defines a reusable custom type (object shape).
        #
        # Custom types can be referenced by name in `param` definitions.
        # Scoped types are namespaced to a contract class.
        #
        # @param name [Symbol] type name for referencing
        # @param scope [Class] a {Contract::Base} subclass for scoping (nil for global)
        # @param description [String] documentation description
        # @param example [Object] example value for docs
        # @param format [String] format hint for docs
        # @param deprecated [Boolean] mark as deprecated
        # @param schema_class [Class] a {Schema::Base} subclass for type inference
        # @yield block defining the type's params
        # @see Contract::Base
        # @see Schema::Base
        #
        # @example Global type
        #   type :address do
        #     param :street, type: :string
        #     param :city, type: :string
        #     param :zip, type: :string
        #   end
        #
        # @example Using in a contract
        #   param :shipping_address, type: :address
        def type(
          name,
          scope: nil,
          description: nil,
          example: nil,
          format: nil,
          deprecated: false,
          schema_class: nil,
          &block
        )
          type_registry.register(
            name,
            deprecated:,
            description:,
            example:,
            format:,
            schema_class:,
            scope:,
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
        #   enum :status, values: %w[draft published archived]
        #
        #   # Later in contract:
        #   param :status, enum: :status
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
        # @yield block defining variants using `variant`
        # @see Contract::Base
        #
        # @example
        #   union :payment_method, discriminator: :type do
        #     variant type: :card, tag: 'card' do
        #       param :last_four, type: :string
        #     end
        #     variant type: :bank, tag: 'bank' do
        #       param :account_number, type: :string
        #     end
        #   end
        def union(name, discriminator: nil, scope: nil, &block)
          raise ArgumentError, 'Union requires a block' unless block_given?

          union_builder = TypeRegistry::UnionBuilder.new(discriminator:)
          union_builder.instance_eval(&block)
          type_registry.register_union(name, union_builder.serialize, scope:)
        end

        # @api public
        # Declares error codes that any action in this API may raise.
        #
        # These are included in generated specs (OpenAPI, etc.) as possible
        # error responses. Use `raises` in action definitions for action-specific errors.
        #
        # @param error_code_keys [Array<Symbol>] registered error code keys
        # @raise [ConfigurationError] if error code is not registered
        #
        # @example Common API-wide errors
        #   Apiwork::API.define '/api/v1' do
        #     raises :unauthorized, :forbidden, :not_found
        #   end
        def raises(*error_code_keys)
          error_code_keys = error_code_keys.flatten.uniq
          error_code_keys.each do |error_code_key|
            unless error_code_key.is_a?(Symbol)
              hint = error_code_key.is_a?(Integer) ? " Use :#{ErrorCode.key_for_status(error_code_key)} instead." : ''
              raise ConfigurationError, "raises must be symbols, got #{error_code_key.class}: #{error_code_key}.#{hint}"
            end

            next if ErrorCode.registered?(error_code_key)

            raise ConfigurationError,
                  "Unknown error code :#{error_code_key}. Register it with: " \
                  "Apiwork::ErrorCode.register :#{error_code_key}, status: <status>"
          end
          @structure.raises = error_code_keys
        end

        # @api public
        # Defines API metadata.
        #
        # @yield block evaluated in {Info} context
        # @return [void]
        # @see API::Info
        #
        # @example
        #   info do
        #     title 'My API'
        #     version '1.0.0'
        #   end
        def info(&block)
          info = Info.new
          info.instance_eval(&block)
          @structure.info = info
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
        #     resources :line_items
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
          @exports = Set.new
          @export_configs = {}
          @adapter_config = {}
          @structure = Structure.new(path)
          @type_registry = TypeRegistry.new
          @enum_registry = EnumRegistry.new
          @built_contracts = Set.new
          @key_format = :keep
          @path_format = :keep
          @introspect_cache = {}
          @introspect_contract_cache = {}

          Registry.register(self)
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

        def transform_request(hash)
          transform_request_keys(hash)
        end

        def transform_response(hash)
          transform_response_keys(hash)
        end

        def export_path(name)
          @export_configs.dig(name, :path) || "/.#{name}"
        end

        def export_config(name)
          @export_configs[name] || {}
        end

        def exports?
          @exports.any?
        end

        def type?(name, scope: nil)
          type_registry.exists?(name, scope:)
        end

        def type_definitions(name, scope: nil)
          type_registry.definitions(name, scope:)
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

          resource = @structure.find_resource { |resource| resource.contract_class == contract_class }
          return unless resource

          schema_class = contract_class.schema_class
          return unless schema_class

          built_contracts.add(contract_class)

          contract_registrar = adapter.build_contract_registrar(contract_class)
          adapter.register_contract(contract_registrar, schema_class, build_adapter_actions(resource.actions))
        end

        def ensure_all_contracts_built!
          @structure.each_resource do |resource|
            build_contracts_for_resource(resource)
          end

          capabilities = adapter.build_capabilities(@structure)
          registrar = adapter.build_api_registrar(self)
          adapter.register_api(registrar, capabilities)
        end

        private

        attr_reader :built_contracts

        def transform_request_keys(hash)
          case @key_format
          when :camel, :kebab
            hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
          else
            hash
          end
        end

        def transform_response_keys(hash)
          case @key_format
          when :camel
            hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          when :kebab
            hash.deep_transform_keys { |key| key.to_s.dasherize.to_sym }
          else
            hash
          end
        end

        def build_contracts_for_resource(resource)
          contract_class = resource.resolve_contract_class
          return unless contract_class
          return if built_contracts.include?(contract_class)

          schema_class = contract_class.schema_class
          return unless schema_class

          built_contracts.add(contract_class)

          contract_registrar = adapter.build_contract_registrar(contract_class)
          adapter.register_contract(contract_registrar, schema_class, build_adapter_actions(resource.actions))
        end

        def build_adapter_actions(actions)
          actions.transform_values { |action| Adapter::Action.new(action.name, action.method, action.type) }
        end
      end
    end
  end
end
