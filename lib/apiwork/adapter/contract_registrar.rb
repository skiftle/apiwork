# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Registers contract-scoped types during contract building.
    #
    # Passed to `register_contract` in your adapter. Use to define
    # types specific to a resource contract (request/response shapes).
    #
    # @example Register request body object
    #   def register_contract(registrar, schema_class, actions)
    #     registrar.object :user_input do
    #       string :name
    #       string :email
    #     end
    #   end
    #
    # @example Define action contracts
    #   def register_contract(registrar, schema_class, actions)
    #     actions.each do |name, action|
    #       registrar.action(name) do
    #         # ...
    #       end
    #     end
    #   end
    class ContractRegistrar
      def initialize(contract_class, importing: nil)
        @contract_class = contract_class
        @importing = importing || Set.new
      end

      # @!method object(name, &block)
      #   @api public
      #   Defines a named object type scoped to this contract.
      #   @param name [Symbol] the object name
      #   @yield block defining params
      #   @see Apiwork::Contract::Base.object

      # @!method enum(name, values:)
      #   @api public
      #   Defines an enum type scoped to this contract.
      #   @param name [Symbol] the enum name
      #   @param values [Array<String>] allowed values
      #   @see Apiwork::Contract::Base.enum

      # @!method union(name, &block)
      #   @api public
      #   Defines a union type scoped to this contract.
      #   @param name [Symbol] the union name
      #   @yield block defining variants
      #   @see Apiwork::Contract::Base.union

      # @!method action(name, replace: false, &block)
      #   @api public
      #   Defines an action. Multiple calls to the same action merge definitions.
      #   @param name [Symbol] the action name
      #   @param replace [Boolean] replace existing definition (default: false)
      #   @yield block defining request/response
      #   @return [Action] the action definition
      #   @see Apiwork::Contract::Base.action

      # @!method import(type_name, from:)
      #   @api public
      #   Imports a type from another contract or the API.
      #   @param type_name [Symbol] the type to import
      #   @param from [Class] a {Contract::Base} subclass
      #   @see Apiwork::Contract::Base.import

      # @!method scoped_type_name(name)
      #   @api public
      #   The fully qualified name for a type in this contract's scope.
      #   @param name [Symbol, nil] the local type name
      #   @return [Symbol] the scoped name

      # @!method scoped_enum_name(name)
      #   @api public
      #   The fully qualified name for an enum in this contract's scope.
      #   @param name [Symbol, nil] the local enum name
      #   @return [Symbol] the scoped name

      # @!method find_contract_for_schema(schema_class)
      #   @api public
      #   Finds the contract class for an associated schema.
      #   @param schema_class [Class] a {Schema::Base} subclass
      #   @return [Contract::Base, nil]

      # @!method imports
      #   @api public
      #   The hash of imported types.
      #   @return [Hash] imported types

      delegate :action,
               :enum,
               :enum?,
               :enum_values,
               :find_contract_for_schema,
               :import,
               :imports,
               :object,
               :scoped_enum_name,
               :scoped_type_name,
               :type?,
               :union,
               to: :contract_class

      # @api public
      # Returns a registrar for API-level types.
      # Use this to define or resolve types at the API scope.
      # @return [Adapter::APIRegistrar] the API registrar
      def api_registrar
        @api_registrar ||= APIRegistrar.new(contract_class.api_class)
      end

      # @api public
      # Ensures all feature types are built for an association's contract.
      # Call this before referencing types from another contract.
      #
      # @param association [Schema::Association] the association to import
      # @return [Symbol, nil] the alias name for referencing types, or nil if import failed
      #
      # @example
      #   schema_class.associations.each do |name, association|
      #     if alias_name = registrar.ensure_association_types(association)
      #       reference name, to: :"#{alias_name}_filter"
      #     end
      #   end
      def ensure_association_types(association)
        schema = resolve_association_schema(association)
        return nil unless schema
        return nil if importing?(schema)

        alias_name = schema.root_key.singular.to_sym

        association_contract = if imports.key?(alias_name)
                                 imports[alias_name]
                               else
                                 contract = find_or_infer_contract(schema)
                                 return nil unless contract

                                 import(contract, as: alias_name)
                                 contract
                               end

        with_import_tracking(schema) do
          build_association_types(association_contract, schema)
        end

        alias_name
      end

      private

      attr_reader :contract_class

      def importing?(schema)
        @importing.include?(schema)
      end

      def with_import_tracking(schema)
        @importing.add(schema)
        yield
      ensure
        @importing.delete(schema)
      end

      def resolve_association_schema(association)
        return nil if association.polymorphic?
        return association.schema_class if association.schema_class

        model_class = association.model_class
        return nil unless model_class

        reflection = model_class.reflect_on_association(association.name)
        return nil unless reflection
        return nil if reflection.polymorphic?

        namespace = contract_class.schema_class.name.deconstantize
        "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
      end

      def find_or_infer_contract(schema)
        found = find_contract_for_schema(schema)
        return found if found

        contract_name = schema.name.sub(/Schema$/, 'Contract')
        contract_name.constantize
      rescue NameError
        nil
      end

      def build_association_types(association_contract, schema)
        return unless association_contract.schema?

        association_contract.api_class.ensure_contract_built!(association_contract)

        sub_registrar = self.class.new(association_contract, importing: @importing)
        adapter = contract_class.api_class.adapter

        adapter.capability_instances.each do |capability|
          capability.contract(sub_registrar, schema, {})
        end

        representation_class = adapter.class.representation
        representation_class&.new(schema)&.contract(sub_registrar, schema, {})

        document_class = adapter.class.document
        document_class&.new(schema)&.contract(sub_registrar, schema, {})
      end
    end
  end
end
