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
                    :root_resource,
                    :type_registry

        # @api public
        # The path for this API.
        #
        # @return [String]
        attr_reader :path

        def locale_key
          @locale_key ||= path.delete_prefix('/')
        end

        def namespaces
          @namespaces ||= extract_namespaces(path)
        end

        # @api public
        # Transforms request and response keys.
        #
        # @param format [Symbol, nil] (nil) [:camel, :kebab, :keep, :underscore]
        #   The format.
        # @return [Symbol, nil]
        # @raise [ConfigurationError] if format is invalid
        #
        # @example
        #   key_format :camel
        def key_format(format = nil)
          return @key_format if format.nil?

          valid = %i[keep camel underscore kebab]
          raise ConfigurationError, "key_format must be one of #{valid}" unless valid.include?(format)

          @key_format = format
        end

        # @api public
        # Transforms resource and action names in URL paths.
        #
        # @param format [Symbol, nil] (nil) [:camel, :kebab, :keep, :underscore]
        #   The format.
        # @return [Symbol, nil]
        # @raise [ConfigurationError] if format is invalid
        #
        # @example
        #   path_format :kebab
        def path_format(format = nil)
          return @path_format if format.nil?

          valid = %i[keep kebab camel underscore]
          raise ConfigurationError, "path_format must be one of #{valid}" unless valid.include?(format)

          @path_format = format
        end

        # @api public
        # Enables an export for this API.
        #
        # @param name [Symbol]
        #   The registered export name. Built-in: :openapi, :typescript, :zod.
        # @yield block evaluated in export context
        # @yieldparam export [Configuration]
        # @return [void]
        #
        # @example
        #   export :openapi
        #   export :typescript do
        #     endpoint do
        #       mode :always
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

          return unless block

          block.arity.positive? ? yield(@export_configs[name]) : @export_configs[name].instance_eval(&block)
        end

        # @api public
        # Sets or gets the adapter for this API.
        #
        # @param name [Symbol, nil] (nil)
        #   The registered adapter name.
        # @yield block evaluated in adapter context
        # @yieldparam adapter [Configuration]
        # @return [Adapter::Base, nil]
        #
        # @example
        #   adapter do
        #     pagination do
        #       default_size 25
        #     end
        #   end
        def adapter(name = nil, &block)
          @adapter_name = name if name.is_a?(Symbol)

          if block
            block.arity.positive? ? yield(adapter_config) : adapter_config.instance_eval(&block)
            return
          end

          @adapter ||= adapter_class.new
        end

        def adapter_class
          Adapter.find!(@adapter_name || :standard)
        end

        def adapter_config
          @adapter_config ||= Configuration.new(adapter_class)
        end

        # @api public
        # Defines a reusable object type.
        #
        # @param name [Symbol]
        #   The object name.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param scope [Class<Contract::Base>, nil] (nil)
        #   The contract scope for type prefixing.
        # @yieldparam object [API::Object]
        # @return [void]
        #
        # @example
        #   object :item do
        #     string :description
        #     decimal :amount
        #   end
        def object(
          name,
          deprecated: false,
          description: nil,
          example: nil,
          scope: nil,
          &block
        )
          type_registry.register(
            name,
            deprecated:,
            description:,
            example:,
            scope:,
            kind: :object,
            &block
          )
        end

        # @api public
        # Defines a reusable enumeration type.
        #
        # @param name [Symbol]
        #   The enum name.
        # @param values [Array<String>, nil] (nil)
        #   The allowed values.
        # @param scope [Class<Contract::Base>, nil] (nil)
        #   The contract scope for type prefixing.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [String, nil] (nil)
        #   The example. Metadata included in exports.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @return [void]
        #
        # @example
        #   enum :status, values: %w[draft sent paid]
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
        # @param name [Symbol]
        #   The union name.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param discriminator [Symbol, nil] (nil)
        #   The discriminator field name.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param scope [Class<Contract::Base>, nil] (nil)
        #   The contract scope for type prefixing.
        # @yieldparam union [API::Union]
        # @return [void]
        #
        # @example
        #   union :payment_method, discriminator: :type do
        #     variant tag: 'card' do
        #       object do
        #         string :last_four
        #       end
        #     end
        #   end
        def union(
          name,
          deprecated: false,
          description: nil,
          discriminator: nil,
          example: nil,
          scope: nil,
          &block
        )
          raise ArgumentError, 'Union requires a block' unless block_given?

          type_registry.register(
            name,
            deprecated:,
            description:,
            discriminator:,
            example:,
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
        # @param error_code_keys [Array<Symbol>]
        #   The registered error code keys.
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
        # The info for this API.
        #
        # @yield block for defining API info
        # @yieldparam info [Info]
        # @return [Info, nil]
        #
        # @example instance_eval style
        #   info do
        #     title 'My API'
        #     version '1.0.0'
        #   end
        #
        # @example yield style
        #   info do |info|
        #     info.title 'My API'
        #     info.version '1.0.0'
        #   end
        def info(&block)
          return @info unless block

          @info = Info.new
          block.arity.positive? ? yield(@info) : @info.instance_eval(&block)
          @info
        end

        # @api public
        # Defines a RESTful resource with standard CRUD actions.
        #
        # This is the main method for declaring API endpoints. Creates
        # routes for index, show, create, update, destroy actions.
        # Nested resources and custom actions can be defined in the block.
        #
        # @param name [Symbol]
        #   The resource name (plural).
        # @param concerns [Array<Symbol>, nil] (nil)
        #   The concerns to include.
        # @param constraints [Hash, Proc, nil] (nil)
        #   The route constraints (regex, lambdas).
        # @param contract [String, nil] (nil)
        #   The custom contract path.
        # @param controller [String, nil] (nil)
        #   The custom controller path.
        # @param defaults [Hash, nil] (nil)
        #   The default parameters for routes.
        # @param except [Array<Symbol>, nil] (nil)
        #   The CRUD actions to exclude.
        # @param only [Array<Symbol>, nil] (nil)
        #   The CRUD actions to include.
        # @param param [Symbol, nil] (nil)
        #   The custom parameter name for ID.
        # @param path [String, nil] (nil)
        #   The custom URL path segment.
        # @yield block for nested resources and custom actions
        # @yieldparam resource [Resource]
        # @return [void]
        #
        # @example instance_eval style
        #   resources :invoices do
        #     member { post :archive }
        #     resources :items
        #   end
        #
        # @example yield style
        #   resources :invoices do |resource|
        #     resource.member { |member| member.post :archive }
        #     resource.resources :items
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
          @root_resource.resources(
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
        # @param name [Symbol]
        #   The resource name (singular).
        # @param concerns [Array<Symbol>, nil] (nil)
        #   The concerns to include.
        # @param constraints [Hash, Proc, nil] (nil)
        #   The route constraints (regex, lambdas).
        # @param contract [String, nil] (nil)
        #   The custom contract path.
        # @param controller [String, nil] (nil)
        #   The custom controller path.
        # @param defaults [Hash, nil] (nil)
        #   The default parameters for routes.
        # @param except [Array<Symbol>, nil] (nil)
        #   The CRUD actions to exclude.
        # @param only [Array<Symbol>, nil] (nil)
        #   The CRUD actions to include.
        # @param param [Symbol, nil] (nil)
        #   The custom parameter name for ID.
        # @param path [String, nil] (nil)
        #   The custom URL path segment.
        # @yield block for nested resources and custom actions
        # @yieldparam resource [Resource]
        # @return [void]
        #
        # @example instance_eval style
        #   resource :profile do
        #     resources :settings
        #   end
        #
        # @example yield style
        #   resource :profile do |resource|
        #     resource.resources :settings
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
          @root_resource.resource(
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
        # @param name [Symbol]
        #   The concern name.
        # @yield block defining shared actions/configuration
        # @yieldparam resource [Resource]
        # @return [void]
        #
        # @example instance_eval style
        #   concern :archivable do
        #     member do
        #       post :archive
        #       post :unarchive
        #     end
        #   end
        #
        #   resources :posts, concerns: [:archivable]
        #
        # @example yield style
        #   concern :archivable do |resource|
        #     resource.member do |member|
        #       member.post :archive
        #       member.post :unarchive
        #     end
        #   end
        #
        #   resources :posts, concerns: [:archivable]
        def concern(name, &block)
          @root_resource.concern(name, &block)
        end

        # @api public
        # Applies options to all nested resource definitions.
        #
        # Useful for applying common configuration to a group of resources.
        # Accepts the same options as {#resources}: only, except, defaults,
        # constraints, controller, param, path.
        #
        # @param options [Hash, nil] (nil)
        #   The options to apply to nested resources.
        # @yield block containing resource definitions
        # @yieldparam resource [Resource]
        # @return [void]
        #
        # @example instance_eval style
        #   with_options only: [:index, :show] do
        #     resources :reports
        #     resources :analytics
        #   end
        #
        # @example yield style
        #   with_options only: [:index, :show] do |resource|
        #     resource.resources :reports
        #     resource.resources :analytics
        #   end
        def with_options(options = {}, &block)
          @root_resource.with_options(options, &block)
        end

        def mount(path)
          @path = path
          @locale_key = nil
          @namespaces = nil
          @info = nil
          @raises = []
          @export_configs = {}
          @adapter_config = nil
          @root_resource = Resource.new(self)
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
          key = :"apiwork.apis.#{locale_key}.#{segments.join('.')}"
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

          resource = @root_resource.find_resource { |resource| resource.resolve_contract_class == contract_class }
          actions = resource ? resource.actions : {}

          adapter.register_contract(contract_class, representation_class, actions)
        end

        def ensure_pre_pass_complete!
          return if @pre_pass_complete

          mark_nested_writable_representations!
          adapter.register_api(self)
          @pre_pass_complete = true
        end

        def ensure_all_contracts_built!
          ensure_pre_pass_complete!

          @root_resource.each_resource do |resource|
            build_contracts_for_resource(resource)
          end
        end

        private

        attr_reader :built_contracts

        def extract_namespaces(mount_path)
          return [] if mount_path.nil? || mount_path == '/'

          mount_path.split('/').reject(&:empty?).map { |segment| segment.tr('-', '_').to_sym }
        end

        def mark_nested_writable_representations!
          visited = Set.new
          @root_resource.each_resource do |resource|
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

            target_representation = association.representation_class
            next unless target_representation

            representation_registry.register(target_representation)
            representation_registry.mark(target_representation, :nested_writable)
            mark_writable_associations(target_representation, visited)
          end
        end

        def build_contracts_for_resource(resource)
          contract_class = resource.resolve_contract_class
          return unless contract_class
          return if built_contracts.include?(contract_class)

          representation_class = contract_class.representation_class
          return unless representation_class

          built_contracts.add(contract_class)

          adapter.register_contract(contract_class, representation_class, resource.actions)
        end
      end
    end
  end
end
