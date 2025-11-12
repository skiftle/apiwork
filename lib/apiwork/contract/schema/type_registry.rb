# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Handles type registration and resolution for schemas
      # Manages filter, sort, include, and association types with circular reference protection
      class TypeRegistry
        class << self
          # Determine which filter type to use based on attribute type
          # Returns global built-in filter types from Descriptors::Registry
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

          # Register resource-specific filter type with Descriptors::Registry
          # Uses type references for associations to eliminate circular recursion
          # @param contract_class [Class] The contract class to register types with
          # @param schema_class [Class] The schema class to generate filters for
          # @param visited [Set] Set of visited schema classes (circular reference protection)
          # @param depth [Integer] Current recursion depth (max 3)
          def register_resource_filter_type(contract_class, schema_class, visited: Set.new, depth: 0)
            # Circular reference and depth protection
            return nil if visited.include?(schema_class)
            return nil if depth >= 3

            # Add to visited set
            visited = visited.dup.add(schema_class)

            # Use schema-specific type name to avoid collisions when filtering by associations
            # For the root schema (depth 0), use :filter. For associated schemas, include schema name
            type_name = if depth.zero?
                          :filter
                        else
                          # Convert "Api::V1::CommentSchema" → :comment_filter
                          schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
                          :"#{schema_name}_filter"
                        end

            # Check if already registered with Descriptors::Registry
            existing = Descriptors::Registry.resolve(type_name, contract_class: contract_class)
            return type_name if existing

            # Pre-register type name to prevent infinite recursion
            # We'll populate it with the actual definition below
            Descriptors::Registry.register_local(contract_class, type_name) do
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
                  # Filter object variant
                  # If attribute has enum, also include enum reference in filter variant
                  variant type: filter_type,
                          **(attribute_definition.enum ? { enum: name } : {})
                end
              end

              # Add filters for associations using type references
              schema_class.association_definitions.each do |name, association_definition|
                assoc_resource = TypeRegistry.resolve_association_resource(association_definition)
                next unless assoc_resource
                next if visited.include?(assoc_resource)

                # Register associated resource's filter type (may return nil for max depth)
                assoc_filter_type = TypeRegistry.register_resource_filter_type(
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
          def register_resource_sort_type(contract_class, schema_class, visited: Set.new, depth: 0)
            # Circular reference and depth protection
            return nil if visited.include?(schema_class)
            return nil if depth >= 3

            # Add to visited set
            visited = visited.dup.add(schema_class)

            # Use schema-specific type name to avoid collisions when sorting by associations
            # For the root schema (depth 0), use :sort. For associated schemas, include schema name
            type_name = if depth.zero?
                          :sort
                        else
                          # Convert "Api::V1::CommentSchema" → :comment_sort
                          schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
                          :"#{schema_name}_sort"
                        end

            # Check if already registered with Descriptors::Registry
            existing = Descriptors::Registry.resolve(type_name, contract_class: contract_class)
            return type_name if existing

            # Pre-register type name to prevent infinite recursion
            Descriptors::Registry.register_local(contract_class, type_name) do
              # Add sort for each sortable attribute
              schema_class.attribute_definitions.each do |name, attribute_definition|
                next unless attribute_definition.sortable?

                # Sort direction: asc or desc (references global :sort_direction enum)
                param name, type: :string, enum: :sort_direction, required: false
              end

              # Add sort for associations using type references
              schema_class.association_definitions.each do |name, association_definition|
                assoc_resource = TypeRegistry.resolve_association_resource(association_definition)
                next unless assoc_resource
                next if visited.include?(assoc_resource)

                # Register associated resource's sort type (may return nil for max depth)
                assoc_sort_type = TypeRegistry.register_resource_sort_type(
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
          # @param association_definition [AssociationDefinition] The association definition
          # @return [Class, nil] The associated resource class or nil
          def resolve_association_resource(association_definition)
            # If schema_class is explicitly set, use it
            if association_definition.schema_class
              return association_definition.schema_class if association_definition.schema_class.is_a?(Class)

              begin
                return association_definition.schema_class.constantize
              rescue StandardError
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
            assoc_model_class = begin
              reflection.klass
            rescue StandardError
              nil
            end
            return nil unless assoc_model_class

            # Find the corresponding schema class
            # Convention: Model::User -> Api::V1::UserSchema
            # Support nested models: Model::Nested::User -> Api::V1::UserSchema
            schema_class_name = "Api::V1::#{assoc_model_class.name.demodulize}Schema"
            begin
              schema_class_name.constantize
            rescue StandardError
              nil
            end
          end

          # Register resource-specific include type with Descriptors::Registry
          # Uses type references for associations to eliminate circular recursion
          # @param contract_class [Class] The contract class to register types with
          # @param schema_class [Class] The schema class to generate includes for
          # @param visited [Set] Set of visited schema classes (circular reference protection)
          # @param depth [Integer] Current recursion depth (max 3)
          def register_resource_include_type(contract_class, schema_class, visited: Set.new, depth: 0)
            # Use schema-specific type name to avoid collisions when including nested associations
            # For the root schema (depth 0), use :include. For associated schemas, include schema name
            type_name = if depth.zero?
                          :include
                        else
                          # Convert "Api::V1::CommentSchema" → :comment_include
                          schema_name = schema_class.name.demodulize.underscore.gsub(/_schema$/, '')
                          :"#{schema_name}_include"
                        end

            # Check if already registered with Descriptors::Registry
            existing = Descriptors::Registry.resolve(type_name, contract_class: contract_class)
            return type_name if existing
            return type_name if depth >= 3

            # Add to visited set
            visited = visited.dup.add(schema_class)

            # Pre-register type name to prevent infinite recursion
            # Contract validates structure, Resource applies validated includes
            Descriptors::Registry.register_local(contract_class, type_name) do
              schema_class.association_definitions.each do |name, association_definition|
                assoc_resource = TypeRegistry.resolve_association_resource(association_definition)
                next unless assoc_resource

                # For circular references, just allow boolean (can't nest further)
                # This allows includes like { comments: { post: true } } where post→comments and comments→post
                if visited.include?(assoc_resource)
                  # Circular ref: only allow boolean for non-serializable
                  # Serializable associations don't need params (always included)
                  param name, type: :boolean, required: false unless association_definition.serializable?
                else
                  # Register associated resource's include type (may return nil for max depth)
                  assoc_include_type = TypeRegistry.register_resource_include_type(
                    contract_class,
                    assoc_resource,
                    visited: visited,
                    depth: depth + 1
                  )

                  if association_definition.serializable?
                    # Serializable: allow boolean OR nested includes
                    # Boolean is redundant (always included) but accepted for flexibility
                    # Example: include[comments]=true (OK), include[comments][user]=true (OK)
                  else
                    # Non-serializable: allow either boolean true or nested include hash
                  end
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
          # @param association_definition [AssociationDefinition] The association definition
          # @param visited [Set] Set of visited schema classes (circular reference protection)
          # @return [Symbol, nil] The type name to reference or nil if no schema
          def register_association_type(_contract_class, association_definition, visited: Set.new)
            # Resolve the associated resource schema
            assoc_schema = resolve_association_resource(association_definition)
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
                assoc_schema.attribute_definitions.each do |name, attribute_definition|
                  param name, type: Generator.map_type(attribute_definition.type), required: false
                end

                # Add nested associations recursively
                assoc_schema.association_definitions.each do |name, nested_association_definition|
                  nested_type = TypeRegistry.register_association_type(assoc_contract_class,
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
          def register_contract_enums(contract_class, schema_class)
            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.enum&.any?

              # Register at contract level (not action/definition level)
              # This makes enum available everywhere in this contract
              Descriptors::Registry.register_local_enum(contract_class, name, attribute_definition.enum)
            end
          end
        end
      end
    end
  end
end
