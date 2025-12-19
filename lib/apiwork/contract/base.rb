# frozen_string_literal: true

module Apiwork
  module Contract
    class Base
      include Abstractable

      class_attribute :action_definitions, instance_accessor: false
      class_attribute :imports, instance_accessor: false
      class_attribute :_identifier
      class_attribute :_schema_class

      # @api private
      attr_reader :action_name,
                  :body,
                  :issues,
                  :query

      def initialize(query:, body:, action_name:, coerce: false)
        result = RequestParser.new(self.class, action_name, coerce:).parse(query, body)
        @query = result.query
        @body = result.body
        @issues = result.issues
        @action_name = action_name.to_sym
      end

      def valid?
        issues.empty?
      end

      def invalid?
        issues.any?
      end

      class << self
        def inherited(subclass)
          super
          subclass.action_definitions = {}
          subclass.imports = {}
        end

        # Sets the scope prefix for contract-scoped types.
        #
        # Types, enums, and unions defined in this contract are namespaced
        # with this prefix in introspection output. For example, a type
        # `:address` becomes `:invoice_address` when identifier is `:invoice`.
        #
        # If not set, prefix is derived from schema's root_key or class name.
        #
        # @param value [Symbol, String] scope prefix (optional)
        # @return [String, nil] the scope prefix
        #
        # @example Custom scope prefix
        #   class InvoiceContract < Apiwork::Contract::Base
        #     identifier :billing
        #
        #     type :address do
        #       param :street, type: :string
        #     end
        #     # In introspection: type is named :billing_address
        #   end
        def identifier(value = nil)
          return _identifier if value.nil?

          self._identifier = value.to_s
        end

        # Links this contract to its schema using naming convention.
        #
        # Looks up the schema class by replacing "Contract" with "Schema"
        # in the class name. For example, `UserContract.schema!` finds
        # `UserSchema`.
        #
        # Call this method to enable auto-generation of request/response
        # types based on the schema's attributes.
        #
        # @return [Class] the associated schema class
        # @raise [ArgumentError] if schema class not found
        #
        # @example
        #   class UserContract < Apiwork::Contract::Base
        #     schema!  # Links to UserSchema
        #
        #     action :create do
        #       request { body { param :name } }
        #       response { body { param :id } }
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
                'Contract and Schema must follow convention: XContract ↔ XSchema'
        end

        # @api private
        def find_contract_for_schema(schema_class)
          return nil unless schema_class

          contract_name = schema_class.name.sub(/Schema$/, 'Contract')
          contract_name.constantize
        rescue NameError
          nil
        end

        # @api private
        def register_sti_variants(*variant_schema_classes)
          variant_schema_classes.each do |variant_class|
            next if variant_class.is_a?(Class) && variant_class < Apiwork::Schema::Base

            raise ArgumentError,
                  "Expected Schema class, got #{variant_class.inspect}. " \
                  'Use: register_sti_variants PersonSchema, CompanySchema'
          end
        end

        # @api private
        def schema_class
          _schema_class
        end

        # @api private
        def schema?
          _schema_class.present?
        end

        # @api private
        def reset_build_state!
          self.action_definitions = {}
          self.imports = {}
        end

        # @api private
        def scope_prefix
          return _identifier if _identifier
          return schema_class.root_key.singular if schema_class

          return nil unless name

          name.demodulize.underscore.gsub(/_(contract|schema)$/, '')
        end

        # Defines a reusable type scoped to this contract.
        #
        # Types are named parameter structures that can be referenced in
        # param definitions. In introspection output, types are namespaced
        # with the contract's scope prefix (e.g., `:order_address`).
        #
        # @param name [Symbol] type name
        # @param description [String] documentation description
        # @param example [Object] example value for docs
        # @param format [String] format hint for docs
        # @param deprecated [Boolean] mark as deprecated
        # @param schema_class [Class] associate with schema for inference
        # @yield block defining the type's params
        #
        # @example Reusable address type
        #   class OrderContract < Apiwork::Contract::Base
        #     type :address do
        #       param :street, type: :string
        #       param :city, type: :string
        #     end
        #
        #     action :create do
        #       request do
        #         body do
        #           param :shipping, type: :address
        #           param :billing, type: :address  # Reuse same type
        #         end
        #       end
        #     end
        #   end
        def type(name, description: nil, example: nil, format: nil, deprecated: false,
                 schema_class: nil, &block)
          api_class.type(name, scope: self, description:, example:, format:, deprecated:,
                               schema_class:, &block)
        end

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
        #
        # @example Status enum
        #   class InvoiceContract < Apiwork::Contract::Base
        #     enum :status, values: %w[draft sent paid]
        #
        #     action :update do
        #       request { body { param :status, enum: :status } }
        #     end
        #   end
        def enum(name, values: nil, description: nil, example: nil, deprecated: false)
          api_class.enum(name, values:, scope: self, description:, example:, deprecated:)
        end

        # Defines a discriminated union type scoped to this contract.
        #
        # A union is a type that can be one of several variants,
        # distinguished by a discriminator field. In introspection
        # output, unions are namespaced with the contract's scope prefix.
        #
        # @param name [Symbol] union name
        # @param discriminator [Symbol] field that identifies the variant
        # @yield block defining variants
        #
        # @example Payment method union
        #   class PaymentContract < Apiwork::Contract::Base
        #     union :method, discriminator: :type do
        #       variant tag: 'card', type: :object do
        #         param :last_four, type: :string
        #       end
        #       variant tag: 'bank', type: :object do
        #         param :account_number, type: :string
        #       end
        #     end
        #   end
        def union(name, discriminator: nil, &block)
          api_class.union(name, scope: self, discriminator:, &block)
        end

        # Imports types from another contract for reuse.
        #
        # Imported types are accessed with a prefix matching the alias.
        # If UserContract defines a type `:address`, importing it as `:user`
        # makes it available as `:user_address`.
        #
        # @param contract_class [Class] the contract class to import from
        # @param as [Symbol] alias prefix for imported types
        #
        # @example Import types from another contract
        #   # UserContract has: type :address, enum :role
        #   class OrderContract < Apiwork::Contract::Base
        #     import UserContract, as: :user
        #
        #     action :create do
        #       request do
        #         body do
        #           param :shipping, type: :user_address   # user_ prefix
        #           param :role, enum: :user_role          # user_ prefix
        #         end
        #       end
        #     end
        #   end
        def import(contract_class, as:)
          unless contract_class.is_a?(Class)
            raise ArgumentError, "import must be a Class constant, got #{contract_class.class}. " \
                                 "Use: import UserContract, as: :user (not 'UserContract' or :user_contract)"
          end

          unless contract_class < Apiwork::Contract::Base
            raise ArgumentError, 'import must be a Contract class (subclass of Apiwork::Contract::Base), ' \
                                 "got #{contract_class}"
          end

          unless as.is_a?(Symbol)
            raise ArgumentError, "import alias must be a Symbol, got #{as.class}. " \
                                 'Use: import UserContract, as: :user'
          end

          imports[as] = contract_class
        end

        # Defines an action (endpoint) for this contract.
        #
        # Actions describe the request/response contract for a specific
        # controller action. Use the block to define request parameters,
        # response format, and documentation.
        #
        # @param action_name [Symbol] the controller action name (:index, :show, :create, :update, :destroy, or custom)
        # @param replace [Boolean] replace existing action definition (default: false)
        # @yield block for defining request/response contract
        # @return [ActionDefinition] the action definition
        #
        # @example Basic CRUD action
        #   class InvoiceContract < Apiwork::Contract::Base
        #     action :show do
        #       request { query { param :include, type: :string, optional: true } }
        #       response { body { param :id } }
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
        #         param :customer_id, type: :integer
        #         param :amount, type: :decimal
        #       end
        #     end
        #
        #     response do
        #       body do
        #         param :id
        #         param :status
        #       end
        #     end
        #
        #     raises :not_found
        #     raises :unprocessable_entity
        #   end
        def action(action_name, replace: false, &block)
          action_name = action_name.to_sym

          action_definition = ActionDefinition.new(action_name:, contract_class: self, replace:)
          action_definition.instance_eval(&block) if block_given?

          action_definitions[action_name] = action_definition
        end

        # @api private
        def resolve_custom_type(type_name, visited: Set.new)
          raise ConfigurationError, "Circular import detected while resolving :#{type_name}" if visited.include?(self)

          result = api_class.resolve_type(type_name, scope: self)
          return result if result

          resolve_imported_type(type_name, visited: visited.dup.add(self))
        end

        # @api private
        def action_definition(action_name)
          api_class&.ensure_contract_built!(self)

          action_name = action_name.to_sym
          action_definitions[action_name]
        end

        # @api private
        def introspect(action: nil, locale: nil)
          Apiwork::Introspection.contract(self, action:, locale:)
        end

        # @api private
        def as_json
          introspect
        end

        # @api private
        def api_class
          return @api_class if instance_variable_defined?(:@api_class)
          return nil unless name

          namespace_parts = name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          Apiwork::API.find("/#{namespace_parts.map(&:underscore).join('/')}")
        end

        # @api private
        def parse_response(body, action)
          ResponseParser.new(self, action).parse(body)
        end

        # @api private
        def resolve_type(name)
          resolve_custom_type(name)
        end

        # @api private
        def resolve_enum(enum_name, visited: Set.new)
          return nil if visited.include?(self)

          result = api_class.resolve_enum(enum_name, scope: self)
          return result if result

          resolve_imported_enum(enum_name, visited: visited.dup.add(self))
        end

        # @api private
        def scoped_name(name)
          api_class.scoped_name(self, name)
        end

        # @api private
        def define_action(action_name, &block)
          action_name = action_name.to_sym

          action_definition = action_definitions[action_name] ||= ActionDefinition.new(
            action_name:,
            contract_class: self
          )

          action_definition.instance_eval(&block) if block_given?
          action_definition
        end

        private

        def resolve_imported_type(type_name, visited:)
          imports.each do |import_alias, imported_contract|
            prefix = "#{import_alias}_"
            next unless type_name.to_s.start_with?(prefix)

            unprefixed_name = type_name.to_s.sub(prefix, '').to_sym
            result = imported_contract.resolve_custom_type(unprefixed_name, visited:)
            return result if result
          end

          nil
        end

        def resolve_imported_enum(enum_name, visited:)
          imports.each do |import_alias, imported_contract|
            prefix = "#{import_alias}_"
            next unless enum_name.to_s.start_with?(prefix)

            unprefixed_name = enum_name.to_s.sub(prefix, '').to_sym
            result = imported_contract.resolve_enum(unprefixed_name, visited:)
            return result if result
          end

          nil
        end
      end
    end
  end
end
