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
    #   Whether this contract is abstract.
    #   @return [Boolean]
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
      # The request for this contract.
      #
      # @return [Request]
      attr_reader :request

      # @api public
      # The issues for this contract.
      #
      # @return [Array<Issue>]
      attr_reader :issues

      # @api public
      # The action name for this contract.
      #
      # @return [Symbol]
      attr_reader :action_name

      # @api public
      # The query for this contract.
      #
      # @return [Hash]
      # @see Request#query
      delegate :query, to: :request

      # @api public
      # The body for this contract.
      #
      # @return [Hash]
      # @see Request#body
      delegate :body, to: :request

      class << self
        # @api public
        # Prefixes types, enums, and unions in introspection output.
        #
        # Must be unique within the API. Derived from the contract class
        # name when not set (e.g., `RecurringInvoiceContract` becomes
        # `recurring_invoice`).
        #
        # @param value [Symbol, String, nil] (nil)
        #   The identifier prefix.
        # @return [String, nil]
        #
        # @example
        #   class InvoiceContract < Apiwork::Contract::Base
        #     identifier :billing
        #
        #     object :address do
        #       string :street
        #     end
        #     # In introspection: :address becomes :billing_address
        #   end
        def identifier(value = nil)
          return _identifier if value.nil?

          self._identifier = value.to_s
        end

        # @api public
        # Configures the representation class for this contract.
        #
        # Adapters use the representation to auto-generate request/response
        # types. Use {.representation_class} to retrieve.
        #
        # @param klass [Class<Representation::Base>]
        #   The representation class.
        # @return [void]
        # @raise [ArgumentError] if klass is not a Representation subclass
        #
        # @example
        #   class InvoiceContract < Apiwork::Contract::Base
        #     representation InvoiceRepresentation
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
        # @param name [Symbol]
        #   The type name.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param format [String, nil] (nil)
        #   The format. Metadata included in exports.
        # @param representation_class [Class<Representation::Base>, nil] (nil)
        #   The representation class for auto-generating fields.
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
        # @param name [Symbol]
        #   The enum name.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [String, nil] (nil)
        #   The example. Metadata included in exports.
        # @param values [Array<String>, nil] (nil)
        #   The allowed values.
        # @return [void]
        #
        # @example
        #   enum :status, values: %w[draft sent paid]
        def enum(
          name,
          deprecated: false,
          description: nil,
          example: nil,
          values: nil
        )
          api_class.enum(name, deprecated:, description:, example:, values:, scope: self)
        end

        # @api public
        # Defines a discriminated union type scoped to this contract.
        #
        # @param name [Symbol]
        #   The union name.
        # @param discriminator [Symbol, nil] (nil)
        #   The discriminator field name.
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
        def union(name, discriminator: nil, &block)
          api_class.union(name, discriminator:, scope: self, &block)
        end

        # @api public
        # Imports types from another contract for reuse.
        #
        # Imported types are accessed with a prefix matching the alias.
        #
        # @param contract_class [Class<Contract::Base>]
        #   The contract class to import types from.
        # @param as [Symbol]
        #   The alias prefix.
        # @return [void]
        # @raise [ArgumentError] if contract_class is not a Contract subclass
        # @raise [ArgumentError] if as is not a Symbol
        #
        # @example
        #   import UserContract, as: :user
        #   # UserContract's :address becomes :user_address
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
        # Defines an action on this contract.
        #
        # @param action_name [Symbol]
        #   The action name. Standard actions: `:index`, `:show`, `:create`, `:update`, `:destroy`.
        # @param replace [Boolean] (false)
        #   Whether to replace an existing action definition.
        # @yieldparam action [Contract::Action]
        # @return [Contract::Action]
        #
        # @example
        #   action :show do
        #     request do
        #       query do
        #         string? :include
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
        # Returns introspection data for this contract.
        #
        # @param expand [Boolean] (false)
        #   Whether to expand all types inline.
        # @param locale [Symbol, nil] (nil)
        #   The locale for translations.
        # @return [Hash]
        #
        # @example
        #   InvoiceContract.introspect
        def introspect(expand: false, locale: nil)
          api_class.introspect_contract(self, expand:, locale:)
        end

        def synthetic?
          _synthetic
        end

        def inherited(subclass)
          super
          subclass.actions = {}
          subclass.imports = {}
        end

        def contract_for(representation_class)
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

        # @api public
        # The representation class for this contract.
        #
        # @return [Class<Representation::Base>, nil]
        # @see .representation
        def representation_class
          _representation_class
        end

        def representation?
          _representation_class.present?
        end

        def scope_prefix
          return _identifier if _identifier
          return nil unless name

          name
            .demodulize
            .delete_suffix('Contract')
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
          return @api_class if @api_class
          return nil unless name

          namespace = name.deconstantize
          return nil if namespace.blank?

          API.find("/#{namespace.underscore.tr('::', '/')}")
        end

        def parse_response(response, action)
          ResponseParser.parse(self, action, response)
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
        result = RequestParser.parse(self.class, action_name, request, coerce:)
        @request = prepare_request(result.request)
        @action_name = action_name.to_sym
        @issues = result.issues
      end

      # @api public
      # Whether this contract is valid.
      #
      # @return [Boolean]
      def valid?
        issues.empty?
      end

      # @api public
      # Whether this contract is invalid.
      #
      # @return [Boolean]
      def invalid?
        issues.any?
      end

      private

      def normalize_request(request)
        api_class = self.class.api_class
        result = api_class.normalize_request(request)
        api_class.adapter.apply_request_transformers(result, phase: :before)
      end

      def prepare_request(request)
        api_class = self.class.api_class
        result = api_class.prepare_request(request)
        api_class.adapter.apply_request_transformers(result, phase: :after)
      end
    end
  end
end
