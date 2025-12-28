# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    class Base
      class << self
        attr_reader :adapter_config,
                    :built_contracts,
                    :path,
                    :spec_configs,
                    :specs,
                    :structure,
                    :type_system

        def mount(path)
          @path = path
          @specs = Set.new
          @spec_configs = {}
          @type_system = TypeSystem.new
          @built_contracts = Set.new
          @key_format = :keep
          @path_format = :keep

          @introspect_contract_cache = {}

          @structure = Structure.new(path)

          Registry.register(self)

          @adapter_config = {}
        end

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

        # @api public
        # Enables a spec generator for this API.
        #
        # Specs generate client code and documentation from your contracts.
        # Available specs: :openapi, :typescript, :zod, :introspection.
        #
        # @param type [Symbol] spec type to enable
        # @yield optional configuration block
        #
        # @example Enable OpenAPI spec
        #   Apiwork::API.define '/api/v1' do
        #     spec :openapi
        #   end
        #
        # @example With custom path
        #   spec :typescript do
        #     path '/types.ts'
        #   end
        def spec(type, &block)
          unless Spec.registered?(type)
            available = Spec.all.join(', ')
            raise ConfigurationError,
                  "Unknown spec: :#{type}. " \
                  "Available: #{available}"
          end

          @specs ||= Set.new
          @spec_configs ||= {}

          @specs.add(type)
          @spec_configs[type] ||= {}
          @spec_configs[type][:path] ||= "/.spec/#{type}"

          return unless block

          spec_class = Spec.find(type)
          builder = Configuration::Builder.new(spec_class, @spec_configs[type])
          builder.instance_eval(&block)
        end

        def spec_path(type)
          @spec_configs&.dig(type, :path) || "/.spec/#{type}"
        end

        def spec_config(type)
          @spec_configs&.[](type) || {}
        end

        def specs?
          @specs&.any?
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
        # Configures the adapter for this API.
        #
        # Adapters control serialization, pagination, filtering, and response
        # formatting. Without arguments, uses the built-in :apiwork adapter.
        #
        # @param name [Symbol] adapter name (:apiwork, or a registered custom adapter)
        # @yield optional configuration block
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
          if name.is_a?(Symbol)
            @adapter_name = name
            @adapter_instance = nil
          end

          if block
            @adapter_config ||= {}
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
        def type(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false,
                 schema_class: nil, &block)
          type_system.register_type(name, scope:, description:, example:, format:, deprecated:,
                                          schema_class:, &block)
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
        #
        # @example
        #   enum :status, values: %w[draft published archived]
        #
        #   # Later in contract:
        #   param :status, enum: :status
        def enum(name, values: nil, scope: nil, description: nil, example: nil, deprecated: false)
          raise ArgumentError, 'Values must be an array' if values && !values.is_a?(Array)

          type_system.register_enum(name, values, scope:, description:, example:, deprecated:)
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
        def union(name, scope: nil, discriminator: nil, &block)
          raise ArgumentError, 'Union requires a block' unless block_given?

          union_builder = TypeSystem::UnionBuilder.new(discriminator:)
          union_builder.instance_eval(&block)
          type_system.register_union(name, union_builder.serialize, scope:)
        end

        def resolve_type(name, scope: nil)
          type_system.resolve_type(name, scope:)
        end

        def resolve_enum(name, scope: nil)
          type_system.resolve_enum(name, scope:)
        end

        def scoped_name(scope, name)
          type_system.scoped_name(scope, name)
        end

        # @api public
        # Defines information about this API.
        #
        # Used to set title, version, contact, license,
        # and other API information for generated specs.
        #
        # @yield block with info methods (title, version, contact, license, server, etc.)
        #
        # @example
        #   Apiwork::API.define '/api/v1' do
        #     info do
        #       title 'My API'
        #       version '1.0.0'
        #       contact do
        #         name 'Support'
        #         email 'support@example.com'
        #       end
        #     end
        #   end
        def info(&block)
          builder = Info::Builder.new
          builder.instance_eval(&block)
          @structure.info = builder.info
        end

        # @api public
        # Defines a RESTful resource with standard CRUD actions.
        #
        # This is the main method for declaring API endpoints. Creates
        # routes for index, show, create, update, destroy actions.
        # Nested resources and custom actions can be defined in the block.
        #
        # @param name [Symbol] resource name (plural)
        # @param options [Hash] resource options
        # @option options [Array<Symbol>] :only limit to specific CRUD actions
        # @option options [Array<Symbol>] :except exclude specific CRUD actions
        # @option options [String] :contract custom contract path
        # @option options [String] :controller custom controller path
        # @option options [Array<Symbol>] :concerns concerns to include
        # @yield block for nested resources and custom actions
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
        def resources(name, **options, &block)
          @structure.resources(name, **options, &block)
        end

        # @api public
        # Defines a singular resource (no index action, no :id in URL).
        #
        # Useful for resources where only one instance exists,
        # like user profile or application settings.
        #
        # @param name [Symbol] resource name (singular)
        # @param options [Hash] resource options (same as resources)
        # @yield block for nested resources and custom actions
        #
        # @example
        #   Apiwork::API.define '/api/v1' do
        #     resource :profile
        #     # Routes: GET /profile, PATCH /profile (no index, no :id)
        #   end
        def resource(name, **options, &block)
          @structure.resource(name, **options, &block)
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
        #
        # @param options [Hash] options to apply to nested resources
        # @yield block containing resource definitions
        #
        # @example Namespace resources
        #   Apiwork::API.define '/api/v1' do
        #     with_options namespace: :admin do
        #       resources :users
        #       resources :settings
        #     end
        #   end
        def with_options(options = {}, &block)
          @structure.with_options(options, &block)
        end

        def introspect(locale: nil)
          ensure_all_contracts_built!
          @introspect_cache ||= {}
          @introspect_cache[locale] ||= Apiwork::Introspection.api(self, locale:)
        end

        def introspect_contract(contract_class, locale:, expand:)
          ensure_all_contracts_built!
          cache_key = [contract_class, locale, expand]
          @introspect_contract_cache ||= {}
          @introspect_contract_cache[cache_key] ||= Apiwork::Introspection.contract(contract_class, locale:, expand:)
        end

        def reset_contracts!
          @built_contracts = Set.new
          @introspect_cache = {}
          @introspect_contract_cache = {}
        end

        def ensure_contract_built!(contract_class)
          return if built_contracts.include?(contract_class)

          resource = find_resource_for_contract(contract_class)
          return unless resource

          schema_class = contract_class.schema_class
          return unless schema_class

          built_contracts.add(contract_class)

          contract_registrar = adapter.build_contract_registrar(contract_class)
          adapter.register_contract(contract_registrar, schema_class, actions: resource.actions)
        end

        def ensure_all_contracts_built!
          return unless @structure

          @structure.each_resource do |resource|
            build_contracts_for_resource(resource)
          end

          schema_summary = adapter.build_schema_summary(
            @structure.schemas,
            has_resources: @structure.has_resources?,
            has_index_actions: @structure.has_index_actions?
          )
          registrar = adapter.build_api_registrar(self)
          adapter.register_api(registrar, schema_summary)
        end

        private

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

        def find_resource_for_contract(contract_class)
          @structure&.search_resources do |resource|
            resource if resource.contract == contract_class.name ||
                        resource.contract_class == contract_class
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
          adapter.register_contract(contract_registrar, schema_class, actions: resource.actions)
        end
      end
    end
  end
end
