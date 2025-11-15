# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Handles type registration and resolution for schemas
      # Manages filter, sort, include, and association types with circular reference protection
      class TypeRegistry
        # Maximum recursion depth for nested type generation
        # Prevents excessive nesting in deeply nested associations
        MAX_RECURSION_DEPTH = 3

        class << self
          # Determine which filter type to use based on attribute type
          # Returns global built-in filter types from Descriptor::Registry
          def determine_filter_type(attr_type)
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

          def register_resource_filter_type(contract_class, schema_class, visited: Set.new, depth: 0)
            # Circular reference and depth protection
            return nil if visited.include?(schema_class)
            return nil if depth >= MAX_RECURSION_DEPTH

            # Add to visited set
            visited = visited.dup.add(schema_class)

            # Ensure filter descriptors are registered for this schema's filterable attributes
            Contract::Descriptor::Core.ensure_filter_descriptors_registered(schema_class, api_class: contract_class.api_class)

            # Use schema-specific type name to avoid collisions when filtering by associations
            # For the root schema (depth 0), use :filter. For associated schemas, include schema name
            type_name = build_type_name(schema_class, :filter, depth)

            # Check if already registered with Descriptor::Registry
            existing = Descriptor::Registry.resolve(type_name, contract_class: contract_class)
            return type_name if existing

            # Pre-register type name to prevent infinite recursion
            # We'll populate it with the actual definition below
            Descriptor::Registry.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              # Add logical operators that recursively reference this filter type
              # These allow combining filters with AND, OR, and NOT logic
              param :_and, type: :array, of: type_name, required: false
              param :_or, type: :array, of: type_name, required: false
              param :_not, type: type_name, required: false

              # Add filters for each filterable attribute
              schema_class.attribute_definitions.each do |name, attribute_definition|
                next unless attribute_definition.filterable?

                filter_type = TypeRegistry.determine_filter_type(attribute_definition.type)

                # Support shorthand: allow primitive value OR filter object
                param name, type: :union, required: false do
                  # Primitive value variant (shorthand)
                  # Reference enum by attribute name (registered at contract level)
                  variant type: Generator.map_type(attribute_definition.type),
                          **(attribute_definition.enum ? { enum: name } : {})
                  # Filter object variant (eq, in, contains, etc.)
                  # Don't include enum here - filter_type is already the correct object type
                  variant type: filter_type
                end
              end

              # Add filters for associations using type references
              schema_class.association_definitions.each do |name, association_definition|
                # Skip non-filterable associations
                next unless association_definition.filterable?

                association_resource = TypeRegistry.resolve_association_resource(association_definition)
                next unless association_resource
                next if visited.include?(association_resource)

                # Try to auto-import the association's contract and reuse its filter type
                import_alias = TypeRegistry.auto_import_association_contract(
                  contract_class,
                  association_resource,
                  visited
                )

                association_filter_type = if import_alias
                                            # Reference imported type: e.g., :comment_filter
                                            :"#{import_alias}_filter"
                                          else
                                            # Fall back to creating type in this contract
                                            TypeRegistry.register_resource_filter_type(
                                              contract_class,
                                              association_resource,
                                              visited: visited,
                                              depth: depth + 1
                                            )
                                          end

                # Add association filter parameter using type reference
                param name, type: association_filter_type, required: false if association_filter_type
              end
            end

            type_name
          end

          def register_resource_sort_type(contract_class, schema_class, visited: Set.new, depth: 0)
            # Circular reference and depth protection
            return nil if visited.include?(schema_class)
            return nil if depth >= MAX_RECURSION_DEPTH

            # Add to visited set
            visited = visited.dup.add(schema_class)

            # Ensure sort descriptor is registered if schema has sortable attributes
            Contract::Descriptor::Core.ensure_sort_descriptor_registered(schema_class, api_class: contract_class.api_class)

            # Use schema-specific type name to avoid collisions when sorting by associations
            # For the root schema (depth 0), use :sort. For associated schemas, include schema name
            type_name = build_type_name(schema_class, :sort, depth)

            # Check if already registered with Descriptor::Registry
            existing = Descriptor::Registry.resolve(type_name, contract_class: contract_class)
            return type_name if existing

            # Pre-register type name to prevent infinite recursion
            Descriptor::Registry.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              # Add sort for each sortable attribute
              schema_class.attribute_definitions.each do |name, attribute_definition|
                next unless attribute_definition.sortable?

                # Sort direction: asc or desc (references global :sort_direction enum)
                param name, type: :string, enum: :sort_direction, required: false
              end

              # Add sort for associations using type references
              schema_class.association_definitions.each do |name, association_definition|
                # Skip non-sortable associations
                next unless association_definition.sortable?

                association_resource = TypeRegistry.resolve_association_resource(association_definition)
                next unless association_resource
                next if visited.include?(association_resource)

                # Try to auto-import the association's contract and reuse its sort type
                import_alias = TypeRegistry.auto_import_association_contract(
                  contract_class,
                  association_resource,
                  visited
                )

                association_sort_type = if import_alias
                                          # Reference imported type: e.g., :comment_sort
                                          :"#{import_alias}_sort"
                                        else
                                          # Fall back to creating type in this contract
                                          TypeRegistry.register_resource_sort_type(
                                            contract_class,
                                            association_resource,
                                            visited: visited,
                                            depth: depth + 1
                                          )
                                        end

                # Add association sort parameter using type reference
                param name, type: association_sort_type, required: false if association_sort_type
              end
            end

            type_name
          end

          def resolve_association_resource(association_definition)
            # If schema_class is explicitly set, use it
            if association_definition.schema_class
              return association_definition.schema_class if association_definition.schema_class.is_a?(Class)

              begin
                return association_definition.schema_class.constantize
              rescue NameError
                nil
              end
            end

            # Get the model class from the association definition
            model_class = association_definition.model_class
            return nil unless model_class

            # Get the ActiveRecord reflection for this association
            reflection = model_class.reflect_on_association(association_definition.name)
            return nil unless reflection

            # Get the associated model class from the reflection
            association_model_class = begin
              reflection.klass
            rescue ActiveRecord::AssociationNotFoundError, NameError
              nil
            end
            return nil unless association_model_class

            # Find the corresponding schema class
            # Convention: Model::User -> Api::V1::UserSchema
            # Support nested models: Model::Nested::User -> Api::V1::UserSchema
            schema_class_name = "Api::V1::#{association_model_class.name.demodulize}Schema"
            begin
              schema_class_name.constantize
            rescue NameError
              nil
            end
          end

          def register_resource_include_type(contract_class, schema_class, visited: Set.new, depth: 0)
            # Use schema-specific type name to avoid collisions when including nested associations
            # For the root schema (depth 0), use :include. For associated schemas, include schema name
            type_name = build_type_name(schema_class, :include, depth)

            # Check if already registered with Descriptor::Registry
            existing = Descriptor::Registry.resolve(type_name, contract_class: contract_class)
            return type_name if existing
            return type_name if depth >= MAX_RECURSION_DEPTH

            # Add to visited set
            visited = visited.dup.add(schema_class)

            # Pre-register type name to prevent infinite recursion
            # Contract validates structure, Resource applies validated includes
            Descriptor::Registry.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              schema_class.association_definitions.each do |name, association_definition|
                association_resource = TypeRegistry.resolve_association_resource(association_definition)
                next unless association_resource

                # For circular references, just allow boolean (can't nest further)
                # This allows includes like { comments: { post: true } } where post→comments and comments→post
                if visited.include?(association_resource)
                  # Circular ref: only allow boolean for non-serializable
                  # Serializable associations don't need params (always included)
                  param name, type: :boolean, required: false unless association_definition.serializable?
                else
                  # Try to auto-import the association's contract and reuse its include type
                  import_alias = TypeRegistry.auto_import_association_contract(
                    contract_class,
                    association_resource,
                    visited
                  )

                  association_include_type = if import_alias
                                               # Reference imported type: e.g., :comment_include
                                               :"#{import_alias}_include"
                                             else
                                               # Fall back to creating type in this contract
                                               TypeRegistry.register_resource_include_type(
                                                 contract_class,
                                                 association_resource,
                                                 visited: visited,
                                                 depth: depth + 1
                                               )
                                             end

                  # Allow boolean OR nested includes for all associations
                  # Serializable: Boolean is redundant (always included) but accepted for flexibility
                  # Non-serializable: Boolean true or nested include hash both supported
                  param name, type: :union, required: false do
                    variant type: :boolean
                    variant type: association_include_type
                  end
                end
              end
            end

            type_name
          end

          def register_association_type(contract_class, association_definition, visited: Set.new)
            # Resolve the associated resource schema
            association_schema = resolve_association_resource(association_definition)
            return nil unless association_schema
            return nil if visited.include?(association_schema)

            # Add to visited set
            visited = visited.dup.add(association_schema)

            # Try to auto-import the association's contract and reuse its resource type
            import_alias = auto_import_association_contract(contract_class, association_schema, visited)

            if import_alias
              # Reference imported type: e.g., :comment
              # The base resource type is the same as the import alias
              return import_alias
            end

            # Fall back to creating a temporary contract for the associated schema
            # This is needed when no contract exists yet
            association_contract_class = Class.new(Base) do
              schema association_schema
            end

            # Register the resource type for the associated schema (using nil as type name)
            resource_type_name = nil

            # Check if already registered
            unless Descriptor::Registry.resolve(resource_type_name, contract_class: association_contract_class)
              Descriptor::Registry.register_type(resource_type_name, scope: association_contract_class,
                                                                     api_class: association_contract_class.api_class) do
                # All resource attributes
                association_schema.attribute_definitions.each do |name, attribute_definition|
                  param name, type: Generator.map_type(attribute_definition.type), required: false
                end

                # Add nested associations recursively
                association_schema.association_definitions.each do |name, nested_association_definition|
                  nested_type = TypeRegistry.register_association_type(association_contract_class,
                                                                       nested_association_definition, visited: visited)

                  if nested_type
                    if nested_association_definition.singular?
                      param name, type: nested_type, required: false, nullable: nested_association_definition.nullable?
                    elsif nested_association_definition.collection?
                      param name, type: :array, of: nested_type, required: false,
                                  nullable: nested_association_definition.nullable?
                    end
                  elsif nested_association_definition.singular?
                    # Fallback to generic types if no schema
                    param name, type: :object, required: false, nullable: nested_association_definition.nullable?
                  elsif nested_association_definition.collection?
                    param name, type: :array, required: false, nullable: nested_association_definition.nullable?
                  end
                end
              end
            end

            # Return the qualified type name for reference
            Descriptor::Registry.qualified_name(association_contract_class, resource_type_name)
          end

          def auto_import_association_contract(parent_contract, association_schema, visited)
            # Guard: circular reference protection
            return nil if visited.include?(association_schema)

            # Find contract via registry
            association_contract = SchemaRegistry.contract_for_schema(association_schema)
            return nil unless association_contract

            # Ensure the association contract has generated its filter/sort/include types
            # This is necessary so that when we reference :comment_filter from PostContract,
            # CommentContract already has :filter registered locally
            # We pass a new visited set to avoid false circular reference detection
            if association_contract.schema?
              register_resource_filter_type(association_contract, association_schema, visited: Set.new, depth: 0)
              register_resource_sort_type(association_contract, association_schema, visited: Set.new, depth: 0)
              register_resource_include_type(association_contract, association_schema, visited: Set.new, depth: 0)
            end

            # Use schema's root_key.singular as alias (convention)
            # Convert to symbol since root_key.singular returns a String
            alias_name = association_schema.root_key.singular.to_sym

            # Import if not already done (idempotent)
            parent_contract.import(association_contract, as: alias_name) unless parent_contract.imports.key?(alias_name)

            alias_name
          end

          def register_contract_enums(contract_class, schema_class)
            api_class = contract_class.api_class

            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.enum&.any?

              # Register at contract level (with filter type generation)
              Descriptor::Registry.register_enum(name, attribute_definition.enum, scope: contract_class, api_class: api_class)

              # Also register at schema level (raw storage only, no filter type)
              # This provides fallback lookup when different contract instances exist (anonymous vs explicit)
              Descriptor::EnumStore.register_enum(name, attribute_definition.enum, scope: schema_class, api_class: api_class)
            end
          end

          private

          def build_type_name(schema_class, base_name, depth)
            return base_name if depth.zero?

            # Convert "Api::V1::CommentSchema" → :comment_filter
            schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
            :"#{schema_name}_#{base_name}"
          end
        end
      end
    end
  end
end
