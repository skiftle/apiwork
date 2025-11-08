# frozen_string_literal: true



module Apiwork
  module Contract
    module Schema
      # Generates implicit contracts from Schema classes
      class Generator
      # Generate an ActionDefinition for a specific action
      # This is used when no explicit contract exists
      # @param schema_class [Class] The schema class to generate from
      # @param action [Symbol] The action name
      # @param contract_class [Class] Optional contract class to use (prevents creating temporary classes)
      # @return [ActionDefinition, nil] Generated action definition or nil
      def self.generate_action(schema_class, action, contract_class: nil)
        return nil unless schema_class

        # Use provided contract class or create a temporary one
        contract_class ||= Class.new(Base) do
          schema schema_class
        end

        # Register all schema enums at contract level ONCE
        # This ensures they're available for all action definitions (create, update, show, index, filters)
        register_contract_enums(contract_class, schema_class)

        # Create and configure the action definition
        action_definition = Apiwork::Contract::ActionDefinition.new(action, contract_class)

        case action.to_sym
        when :index
          action_definition.input do
            Generator.generate_query_params(self, schema_class)
          end
          action_definition.output do
            Generator.generate_collection_output(self, schema_class)
          end
        when :show
          action_definition.input do
            # Empty input - strict mode will reject any query params
          end
          action_definition.output do
            Generator.generate_single_output(self, schema_class)
          end
        when :create
          action_definition.input do
            Generator.generate_writable_input(self, schema_class, :create)
          end
          action_definition.output do
            Generator.generate_single_output(self, schema_class)
          end
        when :update
          action_definition.input do
            Generator.generate_writable_input(self, schema_class, :update)
          end
          action_definition.output do
            Generator.generate_single_output(self, schema_class)
          end
        when :destroy
          # Destroy has no input/output by default
        end

        action_definition
      end

      def self.generate_query_params(definition, schema_class)
        # Get contract class from definition
        contract_class = definition.contract_class

        # Register resource-specific filter and sort types with Descriptors::Registry
        # This pre-registers all types before usage, eliminating circular recursion
        filter_type = register_resource_filter_type(contract_class, schema_class)
        sort_type = register_resource_sort_type(contract_class, schema_class)

        # Generate nested filter parameter with resource-specific filters
        if filter_type
          definition.param :filter, type: :union, required: false do
            # Allow object form
            variant type: filter_type
            # Allow array form
            variant type: :array, of: filter_type
          end
        end

        # Generate nested sort parameter
        if sort_type
          definition.param :sort, type: :union, required: false do
            # Allow single sort field
            variant type: sort_type
            # Allow array of sort fields
            variant type: :array, of: sort_type
          end
        end

        # Generate nested page parameter (uses global built-in type)
        definition.param :page, type: :page_params, required: false

        # Generate nested include parameter with strict validation
        # Type includes ALL associations - contract validates structure
        include_type = register_resource_include_type(contract_class, schema_class)
        definition.param :include, type: include_type, required: false
      end

      # Generate input contract with root key (like params.require(:service).permit(...))
      # Creates: {service: {icon: ..., name: ...}}
      # Registers the payload type with Descriptors::Registry for reusability
      def self.generate_writable_input(definition, schema_class, context)
        root_key = schema_class.root_key.singular.to_sym
        contract_class = definition.contract_class

        # Register the writable payload type with Descriptors::Registry
        # Use short name - Descriptors::Registry will add prefix via qualified_name
        # Example: :create_payload, :update_payload
        payload_type_name = :"#{context}_payload"

        # Check if already registered
        unless Descriptors::Registry.resolve(payload_type_name, contract_class: contract_class)
          Descriptors::Registry.register_local(contract_class, payload_type_name) do
            Generator.generate_writable_params(self, schema_class, context)
          end
        end

        # Create nested param with root key - REQUIRED (no flat format allowed)
        # Use the registered type
        definition.param root_key, type: payload_type_name, required: true
      end

      def self.generate_writable_params(definition, schema_class, context)
        # Generate from writable attributes
        schema_class.attribute_definitions.each do |name, attr_def|
          next unless attr_def.writable_for?(context)

          param_options = {
            type: map_type(attr_def.type),
            required: attr_def.required? # Auto-detected from DB schema and model validations
          }

          # Reference registered enum by attribute name (registered at contract level)
          # E.g., :status references the :post_status enum
          param_options[:enum] = name if attr_def.enum

          definition.param name, **param_options
        end

        # Generate from writable associations
        schema_class.association_definitions.each do |name, assoc_def|
          next unless assoc_def.writable_for?(context)

          param_options = {
            type: assoc_def.singular? ? :object : :array,
            required: false, # Associations are optional by default for input
            nullable: assoc_def.nullable?,
            as: "#{name}_attributes".to_sym # Transform for Rails accepts_nested_attributes_for
          }

          definition.param name, **param_options
        end
      end

      def self.generate_single_output(definition, schema_class)
        root_key = schema_class.root_key.singular.to_sym
        contract_class = definition.contract_class

        # Register the resource type with Descriptors::Registry
        # Use nil - Descriptors::Registry will use just the prefix (e.g., "account")
        # This gives us clean type names like :account, :post, etc.
        resource_type_name = nil

        # Check if already registered
        unless Descriptors::Registry.resolve(resource_type_name, contract_class: contract_class)
          # PRE-REGISTER: Register all association types BEFORE defining the resource type
          # This prevents "can't add a new key into hash during iteration" errors
          assoc_type_map = {}
          schema_class.association_definitions.each do |name, assoc_def|
            assoc_type_map[name] = Generator.register_association_type(contract_class, assoc_def)
          end

          # NOW register the resource type
          Descriptors::Registry.register_local(contract_class, resource_type_name) do
            # All resource attributes
            schema_class.attribute_definitions.each do |name, attr_def|
              param name,
                   type: Generator.map_type(attr_def.type),
                   required: false,
                   **(attr_def.enum ? { enum: name } : {})
            end

            # Add associations using pre-registered types
            schema_class.association_definitions.each do |name, assoc_def|
              assoc_type = assoc_type_map[name]

              if assoc_type
                # Use the registered type
                if assoc_def.singular?
                  param name, type: assoc_type, required: false, nullable: assoc_def.nullable?
                elsif assoc_def.collection?
                  param name, type: :array, of: assoc_type, required: false, nullable: assoc_def.nullable?
                end
              else
                # Fallback to generic types if no schema
                if assoc_def.singular?
                  param name, type: :object, required: false, nullable: assoc_def.nullable?
                elsif assoc_def.collection?
                  param name, type: :array, required: false, nullable: assoc_def.nullable?
                end
              end
            end
          end
        end

        # Full response structure
        definition.param :ok, type: :boolean, required: true

        # Data nested under root key - use the registered type
        definition.param root_key, type: resource_type_name, required: true

        # Meta is optional (only if controller adds it)
        definition.param :meta, type: :object, required: false
      end

      def self.generate_collection_output(definition, schema_class)
        root_key_singular = schema_class.root_key.singular.to_sym
        root_key_plural = schema_class.root_key.plural.to_sym
        contract_class = definition.contract_class

        # Register the resource type with Descriptors::Registry (same as single output)
        # Use nil - Descriptors::Registry will use just the prefix (e.g., "account")
        resource_type_name = nil

        # Check if already registered
        unless Descriptors::Registry.resolve(resource_type_name, contract_class: contract_class)
          # PRE-REGISTER: Register all association types BEFORE defining the resource type
          # This prevents "can't add a new key into hash during iteration" errors
          assoc_type_map = {}
          schema_class.association_definitions.each do |name, assoc_def|
            assoc_type_map[name] = Generator.register_association_type(contract_class, assoc_def)
          end

          # NOW register the resource type
          Descriptors::Registry.register_local(contract_class, resource_type_name) do
            # Each item has all resource attributes
            schema_class.attribute_definitions.each do |name, attr_def|
              param name,
                   type: Generator.map_type(attr_def.type),
                   required: false,
                   **(attr_def.enum ? { enum: name } : {})
            end

            # Add associations using pre-registered types
            schema_class.association_definitions.each do |name, assoc_def|
              assoc_type = assoc_type_map[name]

              if assoc_type
                # Use the registered type
                if assoc_def.singular?
                  param name, type: assoc_type, required: false, nullable: assoc_def.nullable?
                elsif assoc_def.collection?
                  param name, type: :array, of: assoc_type, required: false, nullable: assoc_def.nullable?
                end
              else
                # Fallback to generic types if no schema
                if assoc_def.singular?
                  param name, type: :object, required: false, nullable: assoc_def.nullable?
                elsif assoc_def.collection?
                  param name, type: :array, required: false, nullable: assoc_def.nullable?
                end
              end
            end
          end
        end

        # Full response structure
        definition.param :ok, type: :boolean, required: true

        # Array of items nested under root key - use the registered type
        definition.param root_key_plural, type: :array, required: true, of: resource_type_name

        # Pagination meta (always present for collections)
        definition.param :meta, type: :object, required: true do
          param :page, type: :object, required: true do
            param :current, type: :integer, required: true
            param :next, type: :integer, required: false
            param :prev, type: :integer, required: false
            param :total, type: :integer, required: true
            param :items, type: :integer, required: true
          end
        end
      end

      # Determine which filter type to use based on attribute type
      # Returns global built-in filter types from Descriptors::Registry
      def self.determine_filter_type(attr_type)
        case attr_type
        when :string
          :string_filter
        when :date
          :date_filter
        when :datetime
          :datetime_filter
        when :integer
          :integer_filter
        when :decimal, :float
          :decimal_filter
        when :uuid
          :uuid_filter
        when :boolean
          :boolean_filter
        else
          :string_filter # Default fallback
        end
      end

      # Register resource-specific filter type with Descriptors::Registry
      # Uses type references for associations to eliminate circular recursion
      # @param contract_class [Class] The contract class to register types with
      # @param schema_class [Class] The schema class to generate filters for
      # @param visited [Set] Set of visited schema classes (circular reference protection)
      # @param depth [Integer] Current recursion depth (max 3)
      def self.register_resource_filter_type(contract_class, schema_class, visited: Set.new, depth: 0)
        # Circular reference and depth protection
        return nil if visited.include?(schema_class)
        return nil if depth >= 3

        # Add to visited set
        visited = visited.dup.add(schema_class)

        # Use short name for registration - Descriptors::Registry will add prefix via qualified_name
        type_name = :filter

        # Check if already registered with Descriptors::Registry
        existing = Descriptors::Registry.resolve(type_name, contract_class: contract_class)
        return type_name if existing

        # Pre-register type name to prevent infinite recursion
        # We'll populate it with the actual definition below
        Descriptors::Registry.register_local(contract_class, type_name) do
          # Add filters for each filterable attribute
          schema_class.attribute_definitions.each do |name, attr_def|
            next unless attr_def.filterable?

            filter_type = Generator.determine_filter_type(attr_def.type)

            # Support shorthand: allow primitive value OR filter object
            param name, type: :union, required: false do
              # Primitive value variant (shorthand)
              # Reference enum by attribute name (registered at contract level)
              variant type: Generator.map_type(attr_def.type),
                      **(attr_def.enum ? { enum: name } : {})
              # Filter object variant
              variant type: filter_type
            end
          end

          # Add filters for associations using type references
          schema_class.association_definitions.each do |name, assoc_def|
            assoc_resource = Generator.resolve_association_resource(assoc_def)
            next unless assoc_resource
            next if visited.include?(assoc_resource)

            # Register associated resource's filter type (may return nil for max depth)
            assoc_filter_type = Generator.register_resource_filter_type(
              contract_class,
              assoc_resource,
              visited: visited,
              depth: depth + 1
            )

            # Add association filter parameter using type reference
            param name, type: assoc_filter_type, required: false if assoc_filter_type
          end
        end

        type_name
      end

      # Register resource-specific sort type with Descriptors::Registry
      # Uses type references for associations to eliminate circular recursion
      # @param contract_class [Class] The contract class to register types with
      # @param schema_class [Class] The schema class to generate sorts for
      # @param visited [Set] Set of visited schema classes (circular reference protection)
      # @param depth [Integer] Current recursion depth (max 3)
      def self.register_resource_sort_type(contract_class, schema_class, visited: Set.new, depth: 0)
        # Circular reference and depth protection
        return nil if visited.include?(schema_class)
        return nil if depth >= 3

        # Add to visited set
        visited = visited.dup.add(schema_class)

        # Use short name for registration - Descriptors::Registry will add prefix via qualified_name
        type_name = :sort

        # Check if already registered with Descriptors::Registry
        existing = Descriptors::Registry.resolve(type_name, contract_class: contract_class)
        return type_name if existing

        # Pre-register type name to prevent infinite recursion
        Descriptors::Registry.register_local(contract_class, type_name) do
          # Add sort for each sortable attribute
          schema_class.attribute_definitions.each do |name, attr_def|
            next unless attr_def.sortable?

            # Sort direction: asc or desc (references global :sort_direction enum)
            param name, type: :string, enum: :sort_direction, required: false
          end

          # Add sort for associations using type references
          schema_class.association_definitions.each do |name, assoc_def|
            assoc_resource = Generator.resolve_association_resource(assoc_def)
            next unless assoc_resource
            next if visited.include?(assoc_resource)

            # Register associated resource's sort type (may return nil for max depth)
            assoc_sort_type = Generator.register_resource_sort_type(
              contract_class,
              assoc_resource,
              visited: visited,
              depth: depth + 1
            )

            # Add association sort parameter using type reference
            param name, type: assoc_sort_type, required: false if assoc_sort_type
          end
        end

        type_name
      end

      # Resolve the resource class from an association definition
      # @param assoc_def [AssociationDefinition] The association definition
      # @return [Class, nil] The associated resource class or nil
      def self.resolve_association_resource(assoc_def)
        # If schema_class is explicitly set, use it
        if assoc_def.schema_class
          return assoc_def.schema_class if assoc_def.schema_class.is_a?(Class)
          return assoc_def.schema_class.constantize rescue nil
        end

        # Get the model class from the association definition
        model_class = assoc_def.model_class
        return nil unless model_class

        # Get the ActiveRecord reflection for this association
        reflection = model_class.reflect_on_association(assoc_def.name)
        return nil unless reflection

        # Get the associated model class from the reflection
        assoc_model_class = reflection.klass rescue nil
        return nil unless assoc_model_class

        # Find the corresponding schema class
        # Convention: Model::User -> Api::V1::UserSchema
        # Support nested models: Model::Nested::User -> Api::V1::UserSchema
        schema_class_name = "Api::V1::#{assoc_model_class.name.demodulize}Schema"
        schema_class_name.constantize rescue nil
      end

      # Register resource-specific include type with Descriptors::Registry
      # Uses type references for associations to eliminate circular recursion
      # @param contract_class [Class] The contract class to register types with
      # @param schema_class [Class] The schema class to generate includes for
      # @param visited [Set] Set of visited schema classes (circular reference protection)
      # @param depth [Integer] Current recursion depth (max 3)
      def self.register_resource_include_type(contract_class, schema_class, visited: Set.new, depth: 0)
        # Use short name for registration - Descriptors::Registry will add prefix via qualified_name
        type_name = :include

        # Check if already registered with Descriptors::Registry
        existing = Descriptors::Registry.resolve(type_name, contract_class: contract_class)
        return type_name if existing
        return type_name if depth >= 3

        # Add to visited set
        visited = visited.dup.add(schema_class)

        # Pre-register type name to prevent infinite recursion
        # Contract validates structure, Resource applies validated includes
        Descriptors::Registry.register_local(contract_class, type_name) do
          schema_class.association_definitions.each do |name, assoc_def|
            assoc_resource = Generator.resolve_association_resource(assoc_def)
            next unless assoc_resource

            # For circular references, just allow boolean (can't nest further)
            # This allows includes like { comments: { post: true } } where post→comments and comments→post
            if visited.include?(assoc_resource)
              # Just allow boolean variant for circular refs (can't nest further)
              param name, type: :boolean, required: false
            else
              # Register associated resource's include type (may return nil for max depth)
              assoc_include_type = Generator.register_resource_include_type(
                contract_class,
                assoc_resource,
                visited: visited,
                depth: depth + 1
              )

              # Allow either boolean true or nested include hash
              param name, type: :union, required: false do
                variant type: :boolean
                variant type: assoc_include_type
              end
            end
          end
        end

        type_name
      end

      # Register a type for an associated resource schema
      # This allows associations to reference their schema types instead of generic :object
      # @param contract_class [Class] The contract class to register types with
      # @param assoc_def [AssociationDefinition] The association definition
      # @param visited [Set] Set of visited schema classes (circular reference protection)
      # @return [Symbol, nil] The type name to reference or nil if no schema
      def self.register_association_type(contract_class, assoc_def, visited: Set.new)
        # Resolve the associated resource schema
        assoc_schema = resolve_association_resource(assoc_def)
        return nil unless assoc_schema
        return nil if visited.include?(assoc_schema)

        # Add to visited set
        visited = visited.dup.add(assoc_schema)

        # Create a temporary contract class for the associated schema
        # This is needed to get the proper qualified type name
        assoc_contract_class = Class.new(Base) do
          schema assoc_schema
        end

        # Register the resource type for the associated schema (using nil as type name)
        resource_type_name = nil

        # Check if already registered
        unless Descriptors::Registry.resolve(resource_type_name, contract_class: assoc_contract_class)
          Descriptors::Registry.register_local(assoc_contract_class, resource_type_name) do
            # All resource attributes
            assoc_schema.attribute_definitions.each do |name, attr_def|
              param name, type: Generator.map_type(attr_def.type), required: false
            end

            # Add nested associations recursively
            assoc_schema.association_definitions.each do |name, nested_assoc_def|
              nested_type = Generator.register_association_type(assoc_contract_class, nested_assoc_def, visited: visited)

              if nested_type
                if nested_assoc_def.singular?
                  param name, type: nested_type, required: false, nullable: nested_assoc_def.nullable?
                elsif nested_assoc_def.collection?
                  param name, type: :array, of: nested_type, required: false, nullable: nested_assoc_def.nullable?
                end
              else
                # Fallback to generic types if no schema
                if nested_assoc_def.singular?
                  param name, type: :object, required: false, nullable: nested_assoc_def.nullable?
                elsif nested_assoc_def.collection?
                  param name, type: :array, required: false, nullable: nested_assoc_def.nullable?
                end
              end
            end
          end
        end

        # Return the qualified type name for reference
        Descriptors::Registry.qualified_name(assoc_contract_class, resource_type_name)
      end

      # Register all schema enums at contract level for reuse
      #
      # Enums are registered ONCE per contract and can be referenced in:
      # - Input schemas (create/update)
      # - Output schemas (show/index)
      # - Filter variants
      #
      # @param contract_class [Class] Contract class to register enums with
      # @param schema_class [Class] Schema class containing attribute definitions
      #
      # @example
      #   # For PostContract with status attribute:
      #   register_contract_enums(PostContract, PostSchema)
      #   # Registers: :status -> [:draft, :published]
      #   # Qualified as: :post_status in enums hash
      #   # Referenced as: enum: :status in params
      def self.register_contract_enums(contract_class, schema_class)
        schema_class.attribute_definitions.each do |name, attr_def|
          next unless attr_def.enum&.any?

          # Register at contract level (not action/definition level)
          # This makes enum available everywhere in this contract
          Descriptors::Registry.register_local_enum(contract_class, name, attr_def.enum)
        end
      end

      def self.map_type(resource_type)
        case resource_type
        when :string then :string
        when :integer then :integer
        when :boolean then :boolean
        when :datetime then :datetime
        when :date then :date
        when :uuid then :uuid
        when :decimal, :float then :decimal
        when :object then :object
        when :array then :array
        else :string
        end
      end
      end
    end
  end
end
