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

          # Unified method to determine filter type for any attribute (enum or primitive)
          def filter_type_for(attribute_definition, contract_class)
            return enum_filter_type(attribute_definition, contract_class) if attribute_definition.enum

            determine_filter_type(attribute_definition.type)
          end

          # Get filter type for enum attributes
          def enum_filter_type(attribute_definition, contract_class)
            scoped_enum_name = Descriptor::EnumStore.scoped_name(contract_class, attribute_definition.name)
            :"#{scoped_enum_name}_filter"
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
            existing = Descriptor::Registry.resolve_type(type_name, contract_class: contract_class)
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

                # Determine filter type (enum-specific or primitive)
                filter_type = TypeRegistry.filter_type_for(attribute_definition, contract_class)

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
            existing = Descriptor::Registry.resolve_type(type_name, contract_class: contract_class)
            return type_name if existing

            # Pre-register type name to prevent infinite recursion
            Descriptor::Registry.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              # Add sort for each sortable attribute
              schema_class.attribute_definitions.each do |name, attribute_definition|
                next unless attribute_definition.sortable?

                # Sort direction: asc or desc (references global :sort_direction enum)
                param name, type: :sort_direction, required: false
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

          def register_resource_page_type(contract_class, schema_class)
            # Resolve max_page_size through full inheritance chain (contract → schema → api)
            resolved_max_page_size = Configuration::Resolver.resolve(:max_page_size, contract_class: contract_class, schema_class: schema_class,
                                                                                     api_class: contract_class.api_class)
            api_max_page_size = Configuration::Resolver.resolve(:max_page_size, api_class: contract_class.api_class)

            # If resolved max is same as API default, use global :page type
            return :page if resolved_max_page_size == api_max_page_size

            # Generate schema-specific page type name using same logic as filter/sort
            type_name = build_type_name(schema_class, :page, 1)

            # Check if already registered
            existing = Descriptor::Registry.resolve_type(type_name, contract_class: contract_class)
            return type_name if existing

            # Register new page type with resolved max (global scope, no contract prefix)
            Descriptor::Registry.register_type(type_name, api_class: contract_class.api_class) do
              param :number, type: :integer, required: false, min: 1
              param :size, type: :integer, required: false, min: 1, max: resolved_max_page_size
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
            existing = Descriptor::Registry.resolve_type(type_name, contract_class: contract_class)
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
                  # Circular ref: only allow boolean for :optional associations
                  # :always associations don't need params (always included)
                  param name, type: :boolean, required: false unless association_definition.always_included?
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

                  # For :always associations: only nested includes (no boolean)
                  # For :optional associations: boolean OR nested includes
                  if association_definition.always_included?
                    # Only nested hash, no boolean variant
                    param name, type: association_include_type, required: false
                  else
                    # Boolean or nested hash
                    param name, type: :union, required: false do
                      variant type: :boolean
                      variant type: association_include_type
                    end
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

            # Try to auto-import the association's contract and reuse its resource type
            # Pass the current visited set (before adding this schema) so that auto_import
            # can import the contract and register its types
            import_alias = auto_import_association_contract(contract_class, association_schema, visited)

            # Add to visited set AFTER auto-import to allow bidirectional associations
            visited = visited.dup.add(association_schema)

            if import_alias
              # Ensure the base resource output type is registered for the imported contract
              # This is necessary for schemas that don't have their own routes
              # We pass a new visited set following the same pattern as filter/sort type registration
              association_contract = SchemaRegistry.contract_for_schema(association_schema)
              register_resource_output_type(association_contract, association_schema, visited: Set.new) if association_contract

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
            unless Descriptor::Registry.resolve_type(resource_type_name, contract_class: association_contract_class)
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
            Descriptor::Registry.scoped_name(association_contract_class, resource_type_name)
          end

          def auto_import_association_contract(parent_contract, association_schema, visited)
            # Guard: circular reference protection
            return nil if visited.include?(association_schema)

            # Find contract via registry
            association_contract = SchemaRegistry.contract_for_schema(association_schema)
            return nil unless association_contract

            # Use schema's root_key.singular as alias (convention)
            # Convert to symbol since root_key.singular returns a String
            alias_name = association_schema.root_key.singular.to_sym

            # Import FIRST, before registering types, so that when the type definition blocks
            # are evaluated later (during serialization), the imports are already in place
            parent_contract.import(association_contract, as: alias_name) unless parent_contract.imports.key?(alias_name)

            # Ensure the association contract has generated its types
            # This is necessary so that when we reference :comment_filter from PostContract,
            # CommentContract already has :filter registered locally
            # We pass a new visited set to avoid false circular reference detection
            if association_contract.schema?
              register_resource_filter_type(association_contract, association_schema, visited: Set.new, depth: 0)
              register_resource_sort_type(association_contract, association_schema, visited: Set.new, depth: 0)
              register_resource_include_type(association_contract, association_schema, visited: Set.new, depth: 0)
              register_nested_payload_union(association_contract, association_schema)
              # Also register base resource output type for introspection
              # This ensures schemas without routes still appear in introspection
              register_resource_output_type(association_contract, association_schema, visited: Set.new)
            end

            alias_name
          end

          def register_contract_enums(contract_class, schema_class)
            api_class = contract_class.api_class

            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.enum&.any?

              # Register at contract level (with filter type generation)
              Descriptor::Registry.register_enum(name, attribute_definition.enum, scope: contract_class, api_class: api_class)
            end
          end

          # Register nested_payload union for schemas used as writable associations
          # This is called lazily when a schema is auto-imported as a writable association
          # Creates three types: nested_create_payload, nested_update_payload, and nested_payload (union)
          def register_nested_payload_union(contract_class, schema_class)
            # Only register if schema has writable attributes or writable associations
            # This ensures schemas can be used as nested payloads in writable associations
            return unless schema_class.attribute_definitions.any? { |_, ad| ad.writable? } ||
                          schema_class.association_definitions.any? { |_, ad| ad.writable? }

            api_class = contract_class.api_class

            # Register nested_create_payload as separate object type
            create_type_name = :nested_create_payload
            unless Descriptor::Registry.resolve_type(create_type_name, contract_class: contract_class)
              Descriptor::Registry.register_type(create_type_name, scope: contract_class, api_class: api_class) do
                param :_type, type: :literal, value: 'create', required: true
                InputGenerator.generate_writable_params(self, schema_class, :create, nested: true)
                # Add _destroy if any association has allow_destroy
                if schema_class.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
                  param :_destroy, type: :boolean, required: false
                end
              end
            end

            # Register nested_update_payload as separate object type
            update_type_name = :nested_update_payload
            unless Descriptor::Registry.resolve_type(update_type_name, contract_class: contract_class)
              Descriptor::Registry.register_type(update_type_name, scope: contract_class, api_class: api_class) do
                param :_type, type: :literal, value: 'update', required: true
                InputGenerator.generate_writable_params(self, schema_class, :update, nested: true)
                # Add _destroy if any association has allow_destroy
                if schema_class.association_definitions.any? { |_, ad| ad.writable? && ad.allow_destroy }
                  param :_destroy, type: :boolean, required: false
                end
              end
            end

            # Create union that references the two separate types
            nested_payload_type_name = :nested_payload
            return if Descriptor::Registry.resolve_type(nested_payload_type_name, contract_class: contract_class)

            # Get qualified names for variant references to match introspection storage
            create_qualified_name = Descriptor::Registry.scoped_name(contract_class, create_type_name)
            update_qualified_name = Descriptor::Registry.scoped_name(contract_class, update_type_name)

            union_def = UnionDefinition.new(contract_class, discriminator: :_type)
            union_def.variant(type: create_qualified_name, tag: 'create')
            union_def.variant(type: update_qualified_name, tag: 'update')
            union_data = union_def.serialize

            # Register as top-level union
            Descriptor::Registry.register_union(nested_payload_type_name, union_data,
                                                scope: contract_class, api_class: api_class)
          end

          # Register base resource output type for schemas (even those without routes)
          # This ensures the type is available for introspection and validation
          def register_resource_output_type(contract_class, schema_class, visited: Set.new)
            # Circular reference protection
            return if visited.include?(schema_class)

            visited.dup.add(schema_class)

            root_key = schema_class.root_key.singular.to_sym
            resource_type_name = Descriptor::Registry.scoped_name(contract_class, nil)

            # Check if already registered (idempotent)
            return if Descriptor::Registry.resolve_type(resource_type_name, contract_class: contract_class)

            # Register the resource type immediately to prevent infinite recursion
            # Then populate it with attributes and associations inside the block
            Descriptor::Registry.register_type(root_key, scope: contract_class, api_class: contract_class.api_class) do
              # PRE-REGISTER: Register all association types inside the block
              # Use a fresh visited set to avoid false circular reference detection
              # (same pattern as filter/sort type registration)
              assoc_type_map = {}
              schema_class.association_definitions.each do |name, association_definition|
                result = TypeRegistry.register_association_type(contract_class, association_definition, visited: Set.new)
                assoc_type_map[name] = result
              end

              # PRE-REGISTER: Register all enum types and add all resource attributes
              schema_class.attribute_definitions.each do |name, attribute_definition|
                # Register enum if present
                if attribute_definition.enum
                  enum_values = attribute_definition.enum
                  Descriptor::Registry.register_enum(name, enum_values, scope: contract_class,
                                                                        api_class: contract_class.api_class)
                end

                # Add attribute to type
                enum_option = attribute_definition.enum ? { enum: name } : {}
                param name,
                      type: Generator.map_type(attribute_definition.type),
                      required: false,
                      **enum_option
              end

              # Add associations using pre-registered types
              schema_class.association_definitions.each do |name, association_definition|
                assoc_type = assoc_type_map[name]
                is_required = association_definition.always_included?

                if assoc_type
                  if association_definition.singular?
                    param name, type: assoc_type, required: is_required, nullable: association_definition.nullable?
                  elsif association_definition.collection?
                    param name, type: :array, of: assoc_type, required: is_required,
                                nullable: association_definition.nullable?
                  end
                elsif association_definition.singular?
                  param name, type: :object, required: is_required, nullable: association_definition.nullable?
                elsif association_definition.collection?
                  param name, type: :array, of: :object, required: is_required, nullable: association_definition.nullable?
                end
              end
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
