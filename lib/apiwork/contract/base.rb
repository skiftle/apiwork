# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Base class for API contracts.
    #
    # Contracts define request/response structure for a resource.
    # Link to a representation with {.representation} for automatic serialization.
    # Define actions with {.action} for custom validation and response shapes.
    #
    # @example Basic contract
    #   class InvoiceContract < Apiwork::Contract::Base
    #     representation InvoiceRepresentation
    #   end
    #
    # @example With custom actions
    #   class InvoiceContract < Apiwork::Contract::Base
    #     representation InvoiceRepresentation
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
      class_attribute :_representation_class, instance_accessor: false
      class_attribute :_building, default: false, instance_accessor: false
      class_attribute :_synthetic_contracts, default: {}, instance_accessor: false
      class_attribute :_synthetic, default: false, instance_accessor: false

      # @api public
      # @return [Request] the parsed and validated request
      attr_reader :request

      # @api public
      # @return [Array<Issue>] validation issues (empty if valid)
      attr_reader :issues

      # @api public
      # @return [Symbol] the current action name
      attr_reader :action_name

      # @api public
      # @return [Hash] parsed and validated query parameters
      delegate :query, to: :request

      # @api public
      # @return [Hash] parsed and validated request body
      delegate :body, to: :request

      class << self
        attr_writer :api_class

        def synthetic?
          _synthetic
        end

        # @api public
        # The scope prefix for contract-scoped types.
        #
        # Types, enums, and unions defined in this contract are namespaced
        # with this prefix in introspection output. For example, a type
        # `:address` becomes `:invoice_address` when identifier is `:invoice`.
        #
        # If not set, prefix is derived from representation's root_key or class name.
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
        # Links this contract to a representation class.
        #
        # The representation defines the attributes and associations that
        # are serialized in responses. Adapters use the representation to
        # auto-generate request/response types.
        #
        # @param klass [Class] a {Representation::Base} subclass
        # @return [void]
        # @raise [ArgumentError] if klass is not a Representation subclass
        # @see Representation::Base
        #
        # @example
        #   class InvoiceContract < Apiwork::Contract::Base
        #     representation InvoiceRepresentation
        #
        #     action :show
        #     action :create
        #   end
        def representation(klass)
          unless klass.is_a?(Class) && klass < Representation::Base
            raise ArgumentError,
                  'representation must be a Representation class (subclass of Apiwork::Representation::Base), ' \
                  "got #{klass.inspect}"
          end

          self._representation_class = klass
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
          description: nil,
          example: nil,
          format: nil,
          deprecated: false,
          representation_class: nil,
          &block
        )
          api_class.object(
            name,
            deprecated:,
            description:,
            example:,
            format:,
            representation_class:,
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

          return if contract_class._building
          return unless contract_class.representation? && contract_class.api_class

          contract_class._building = true
          begin
            contract_class.api_class.ensure_contract_built!(contract_class)
          ensure
            contract_class._building = false
          end
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
        # @yield block for defining request/response contract (instance_eval style)
        # @yieldparam builder [Contract::Action] the builder (yield style)
        # @return [Contract::Action] the action definition
        # @see Contract::Action
        #
        # @example instance_eval style
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
        # @example yield style
        #   class InvoiceContract < Apiwork::Contract::Base
        #     action :show do |action|
        #       action.request do |request|
        #         request.query do |query|
        #           query.string? :include
        #         end
        #       end
        #       action.response do |response|
        #         response.body do |body|
        #           body.uuid :id
        #         end
        #       end
        #     end
        #   end
        def action(action_name, replace: false, &block)
          action_name = action_name.to_sym

          action = if replace
                     Action.new(self, action_name, replace: true)
                   else
                     actions[action_name] ||= Action.new(self, action_name)
                   end

          if block_given?
            block.arity.positive? ? yield(action) : action.instance_eval(&block)
          end
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

        def find_contract_for_representation(representation_class)
          return nil unless representation_class&.name

          contract_name = representation_class.name.sub(/Representation\z/, 'Contract')
          contract_class = contract_name.safe_constantize

          return contract_class if contract_class.is_a?(Class) && contract_class < Contract::Base

          _synthetic_contracts[representation_class] ||= build_synthetic_contract(representation_class, api_class)
        end

        def build_synthetic_contract(representation_class, api_class)
          Class.new(Contract::Base) do
            self._synthetic = true
            self._representation_class = representation_class
            @api_class = api_class
          end
        end

        def representation_class
          _representation_class
        end

        def representation?
          _representation_class.present?
        end

        def reset_build_state!
          self.actions = {}
          self.imports = {}
        end

        def scope_prefix
          return _identifier if _identifier
          return representation_class.root_key.singular if representation_class

          return nil unless name

          name
            .demodulize
            .delete_suffix('Contract')
            .delete_suffix('Representation')
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

        def parse_response(response, action)
          ResponseParser.new(self, action).parse(response)
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

      def initialize(action_name, request, coerce: false)
        request = normalize_request(request)
        result = RequestParser.new(self.class, action_name, coerce:).parse(request)
        @request = prepare_request(result.request)
        @action_name = action_name.to_sym
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

      def api_class
        self.class.api_class
      end

      def adapter
        api_class.adapter
      end

      def normalize_request(request)
        result = api_class.normalize_request(request)
        adapter.apply_request_transformers(result, phase: :before)
      end

      def prepare_request(request)
        result = api_class.prepare_request(request)
        adapter.apply_request_transformers(result, phase: :after)
      end
    end
  end
end
