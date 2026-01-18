# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Base class for API contracts.
    #
    # Contracts define request/response structure for a resource.
    # Link to a schema with {.schema!} for automatic serialization.
    # Define actions with {.action} for custom validation and response shapes.
    #
    # @example Basic contract
    #   class InvoiceContract < Apiwork::Contract::Base
    #     schema! InvoiceSchema
    #   end
    #
    # @example With custom actions
    #   class InvoiceContract < Apiwork::Contract::Base
    #     schema! InvoiceSchema
    #
    #     action :create do
    #       request do
    #         body do
    #           string :title
    #           decimal :amount, min: 0
    #         end
    #       end
    #     end
    #   end
    #
    # @!scope class
    # @!method abstract!
    #   @api public
    #   Marks this contract as abstract.
    #
    #   Abstract contracts serve as base classes for other contracts.
    #   Use this when creating application-wide base contracts that define
    #   shared imports or configuration. Subclasses automatically become non-abstract.
    #   @return [void]
    #   @example Application base contract
    #     class ApplicationContract < Apiwork::Contract::Base
    #       abstract!
    #     end
    #
    # @!method abstract?
    #   @api public
    #   Returns whether this contract is abstract.
    #   @return [Boolean] true if abstract
    class Base
      include Abstractable

      class_attribute :actions, instance_accessor: false
      class_attribute :imports, instance_accessor: false
      class_attribute :_identifier, instance_accessor: false
      class_attribute :_schema_class, instance_accessor: false

      # @api public
      # @return [Hash] parsed and validated query parameters
      attr_reader :query

      # @api public
      # @return [Hash] parsed and validated request body
      attr_reader :body

      # @api public
      # @return [Array<Issue>] validation issues (empty if valid)
      attr_reader :issues

      # @api public
      # @return [Symbol] the current action name
      attr_reader :action_name

      class << self
        attr_writer :api_class

        # @api public
        # The scope prefix for contract-scoped types.
        #
        # Types, enums, and unions defined in this contract are namespaced
        # with this prefix in introspection output. For example, a type
        # `:address` becomes `:invoice_address` when identifier is `:invoice`.
        #
        # If not set, prefix is derived from schema's root_key or class name.
        #
        # @param value [Symbol, String] scope prefix (optional)
        # @return [String, nil]
        #
        # @example Custom scope prefix
        #   class InvoiceContract < Apiwork::Contract::Base
        #     identifier :billing
        #
        #     object :address do
        #       string :street
        #     end
        #     # In introspection: object is named :billing_address
        #   end
        def identifier(value = nil)
          return _identifier if value.nil?

          self._identifier = value.to_s
        end

        # @api public
        # Links this contract to its schema using naming convention.
        #
        # Looks up the schema class by replacing "Contract" with "Schema"
        # in the class name. Both must be in the same namespace.
        # For example, `Api::V1::UserContract.schema!` finds `Api::V1::UserSchema`.
        #
        # Call this method to enable auto-generation of request/response
        # types based on the schema's attributes.
        #
        # @return [Schema::Base]
        # @raise [ArgumentError] if schema class not found
        # @see Schema::Base
        #
        # @example
        #   class Api::V1::UserContract < Apiwork::Contract::Base
        #     schema!  # Links to Api::V1::UserSchema
        #
        #     action :create do
        #       request do
        #         body do
        #           param :name
        #         end
        #       end
        #       response do
        #         body do
        #           param :id
        #         end
        #       end
        #     end
        #   end
        def schema!
          return _schema_class if _schema_class

          schema_name = name.sub(/Contract$/, 'Schema')
          schema_class = schema_name.constantize

          self._schema_class = schema_class

          schema_class
        rescue NameError
          raise ArgumentError,
                "Expected to find #{schema_name} in app/schemas/. " \
                'Contract and Schema must follow convention: XContract and XSchema'
        end

        # @api public
        # Defines a reusable object type scoped to this contract.
        #
        # Objects are named parameter structures that can be referenced in
        # param definitions. In introspection output, objects are namespaced
        # with the contract's scope prefix (e.g., `:order_address`).
        #
        # @param name [Symbol] object name
        # @param description [String] documentation description
        # @param example [Object] example value for docs
        # @param format [String] format hint for docs
        # @param deprecated [Boolean] mark as deprecated
        # @param schema_class [Class] a {Schema::Base} subclass for type inference
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
          description: nil,
          example: nil,
          format: nil,
          deprecated: false,
          schema_class: nil,
          &block
        )
          api_class.object(
            name,
            deprecated:,
            description:,
            example:,
            format:,
            schema_class:,
            scope: self,
            &block
          )
        end

        # @api public
        # Defines an enum scoped to this contract.
        #
        # Enums define a set of allowed string values. In introspection
        # output, enums are namespaced with the contract's scope prefix.
        #
        # @param name [Symbol] enum name
        # @param values [Array<String>] allowed string values
        # @param description [String] documentation description
        # @param example [String] example value for docs
        # @param deprecated [Boolean] mark as deprecated
        # @see API::Base
        #
        # @example
        #   enum :status, values: %w[draft sent paid]
        #
        # @example Reference in contract
        #   string :status, enum: :status
        def enum(
          name,
          values: nil,
          description: nil,
          example: nil,
          deprecated: false
        )
          api_class.enum(name, deprecated:, description:, example:, values:, scope: self)
        end

        # @api public
        # Defines a discriminated union type scoped to this contract.
        #
        # A union is a type that can be one of several variants,
        # distinguished by a discriminator field. In introspection
        # output, unions are namespaced with the contract's scope prefix.
        #
        # @param name [Symbol] union name
        # @param discriminator [Symbol] field that identifies the variant
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
        def union(name, discriminator: nil, &block)
          api_class.union(name, discriminator:, scope: self, &block)
        end

        # @api public
        # Imports types from another contract for reuse.
        #
        # Imported types are accessed with a prefix matching the alias.
        # If UserContract defines a type `:address`, importing it as `:user`
        # makes it available as `:user_address`.
        #
        # @param contract_class [Class] a {Contract::Base} subclass to import from
        # @param as [Symbol] alias prefix for imported types
        # @see Contract::Base
        #
        # @example Import types from another contract
        #   # UserContract has: object :address, enum :role
        #   class OrderContract < Apiwork::Contract::Base
        #     import UserContract, as: :user
        #
        #     action :create do
        #       request do
        #         body do
        #           reference :shipping, to: :user_address  # user_ prefix
        #           string :role, enum: :user_role          # user_ prefix
        #         end
        #       end
        #     end
        #   end
        def import(contract_class, as:)
          unless contract_class.is_a?(Class)
            raise ArgumentError,
                  "import must be a Class constant, got #{contract_class.class}. " \
                                                   "Use: import UserContract, as: :user (not 'UserContract' or :user_contract)"
          end

          unless contract_class < Contract::Base
            raise ArgumentError,
                  'import must be a Contract class (subclass of Apiwork::Contract::Base), ' \
                                                   "got #{contract_class}"
          end

          unless as.is_a?(Symbol)
            raise ArgumentError,
                  "import alias must be a Symbol, got #{as.class}. " \
                                                   'Use: import UserContract, as: :user'
          end

          imports[as] = contract_class
        end

        # @api public
        # Defines an action (endpoint) for this contract.
        #
        # Actions describe the request/response contract for a specific
        # controller action. Use the block to define request parameters,
        # response format, and documentation.
        #
        # @param action_name [Symbol] the controller action name (:index, :show, :create, :update, :destroy, or custom)
        # @param replace [Boolean] replace existing action definition (default: false)
        # @yield block for defining request/response contract
        # @return [Contract::Action] the action definition
        # @see Contract::Action
        #
        # @example Basic CRUD action
        #   class InvoiceContract < Apiwork::Contract::Base
        #     action :show do
        #       request do
        #         query do
        #           string? :include
        #         end
        #       end
        #       response do
        #         body do
        #           uuid :id
        #         end
        #       end
        #     end
        #   end
        #
        # @example Action with full request/response
        #   action :create do
        #     summary 'Create a new invoice'
        #     tags :billing
        #
        #     request do
        #       body do
        #         integer :customer_id
        #         decimal :amount
        #       end
        #     end
        #
        #     response do
        #       body do
        #         uuid :id
        #         string :status
        #       end
        #     end
        #
        #     raises :not_found
        #     raises :unprocessable_entity
        #   end
        def action(action_name, replace: false, &block)
          action_name = action_name.to_sym

          action = if replace
                     Action.new(self, action_name, replace: true)
                   else
                     actions[action_name] ||= Action.new(self, action_name)
                   end

          action.instance_eval(&block) if block_given?
          actions[action_name] = action
        end

        # @api public
        # Returns a hash representation of this contract's structure.
        #
        # Includes all actions with their request/response definitions.
        # Useful for generating documentation or client code.
        #
        # @param locale [Symbol] optional locale for translated descriptions
        # @param expand [Boolean] resolve all referenced types (local, imported, global)
        # @return [Hash] contract structure with :actions key
        #
        # @example
        #   InvoiceContract.introspect
        #   # => { actions: { create: { request: {...}, response: {...} } } }
        #
        # @example With all available types
        #   InvoiceContract.introspect(expand: true)
        #   # => { actions: {...}, types: { local: {...}, imported: {...}, global: {...} } }
        def introspect(expand: false, locale: nil)
          api_class.introspect_contract(self, expand:, locale:)
        end

        def inherited(subclass)
          super
          subclass.actions = {}
          subclass.imports = {}
        end

        def find_contract_for_schema(schema_class)
          return nil unless schema_class&.name

          schema_class.name
            .sub(/Schema\z/, 'Contract')
            .safe_constantize
        end

        def schema_class
          _schema_class
        end

        def schema?
          _schema_class.present?
        end

        def reset_build_state!
          self.actions = {}
          self.imports = {}
        end

        def scope_prefix
          return _identifier if _identifier
          return schema_class.root_key.singular if schema_class

          return nil unless name

          name
            .demodulize
            .delete_suffix('Contract')
            .delete_suffix('Schema')
            .underscore
        end

        def resolve_custom_type(type_name, visited: Set.new)
          raise ConfigurationError, "Circular import detected while resolving :#{type_name}" if visited.include?(self)

          result = api_class.type_definition(type_name, scope: self)
          return result if result

          resolve_imported_type(type_name, visited: visited.dup.add(self))
        end

        def action_for(action_name)
          api_class.ensure_contract_built!(self)

          action_name = action_name.to_sym
          actions[action_name]
        end

        def api_class
          return @api_class if instance_variable_defined?(:@api_class)
          return nil unless name

          namespace = name.deconstantize
          return nil if namespace.blank?

          API.find("/#{namespace.underscore.tr('::', '/')}")
        end

        def parse_response(body, action)
          ResponseParser.new(self, action).parse(body)
        end

        def type?(name)
          resolve_custom_type(name).present?
        end

        def enum?(name)
          enum_values(name).present?
        end

        def enum_values(enum_name, visited: Set.new)
          return nil if visited.include?(self)

          result = api_class.enum_values(enum_name, scope: self)
          return result if result

          resolve_imported_enum_values(enum_name, visited: visited.dup.add(self))
        end

        def scoped_type_name(name)
          api_class.scoped_type_name(self, name)
        end

        def scoped_enum_name(name)
          api_class.scoped_enum_name(self, name)
        end

        private

        def resolve_imported_type(type_name, visited:)
          type_string = type_name.to_s

          imports.each do |import_alias, imported_contract|
            prefix = "#{import_alias}_"
            next unless type_string.start_with?(prefix)

            unprefixed_name = type_string.delete_prefix(prefix).to_sym
            result = imported_contract.resolve_custom_type(unprefixed_name, visited:)
            return result if result
          end

          nil
        end

        def resolve_imported_enum_values(enum_name, visited:)
          enum_string = enum_name.to_s

          imports.each do |import_alias, imported_contract|
            prefix = "#{import_alias}_"
            next unless enum_string.start_with?(prefix)

            unprefixed_name = enum_string.delete_prefix(prefix).to_sym
            result = imported_contract.enum_values(unprefixed_name, visited:)
            return result if result
          end

          nil
        end
      end

      def api_class
        self.class.api_class
      end

      def adapter
        api_class.adapter
      end

      def normalize_request(request)
        request = api_class.normalize_request(request)
        adapter.normalize_request(request)
      end

      def prepare_request(request)
        request = api_class.prepare_request(request)
        adapter.prepare_request(request)
      end

      def initialize(action_name, query, body, coerce: false)
        request = Adapter::RequestContext.new(body:, query:)
        request = normalize_request(request)
        result = RequestParser.new(self.class, action_name, coerce:).parse(request)
        request = prepare_request(result.request)

        @action_name = action_name.to_sym
        @query = request.query
        @body = request.body
        @issues = result.issues
      end

      # @api public
      # Returns whether the contract passed validation.
      # @return [Boolean] true if no validation issues
      def valid?
        issues.empty?
      end

      # @api public
      # Returns whether the contract has validation issues.
      # @return [Boolean] true if any validation issues
      def invalid?
        issues.any?
      end
    end
  end
end
