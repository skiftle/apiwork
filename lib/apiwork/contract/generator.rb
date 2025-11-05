# frozen_string_literal: true

require_relative 'action_definition'

module Apiwork
  module Contract
    # Generates implicit contracts from Resource classes
    class Generator
      # Generate an ActionDefinition for a specific action
      # This is used when no explicit contract exists
      # @param resource_class [Class] The resource class to generate from
      # @param action [Symbol] The action name
      # @return [ActionDefinition, nil] Generated action definition or nil
      def self.generate_action(resource_class, action)
        return nil unless resource_class

        # Create a temporary anonymous contract class
        contract_class = Class.new(Base) do
          resource resource_class
        end

        # Create and configure the action definition
        action_def = ActionDefinition.new(action, contract_class)

        case action.to_sym
        when :index
          action_def.input do
            Generator.generate_query_params(self, resource_class)
          end
          action_def.output do
            Generator.generate_collection_output(self, resource_class)
          end
        when :show
          action_def.input do
            # Empty input - strict mode will reject any query params
          end
          action_def.output do
            Generator.generate_single_output(self, resource_class)
          end
        when :create
          action_def.input do
            Generator.generate_writable_input(self, resource_class, :create)
          end
          action_def.output do
            Generator.generate_single_output(self, resource_class)
          end
        when :update
          action_def.input do
            Generator.generate_writable_input(self, resource_class, :update)
          end
          action_def.output do
            Generator.generate_single_output(self, resource_class)
          end
        when :destroy
          # Destroy has no input/output by default
        end

        action_def
      end

      def self.generate_query_params(definition, resource_class)
        # Get contract class from definition
        contract_class = definition.contract_class

        # Define base filter types if not already defined
        define_filter_types(contract_class)

        # Generate resource-specific filter and sort types (with recursive associations)
        filter_type = generate_resource_filter_type(contract_class, resource_class)
        sort_type = generate_resource_sort_type(contract_class, resource_class)

        # Generate nested filter parameter with resource-specific filters
        definition.param :filter, type: :union, required: false do
          # Allow object form
          variant type: filter_type
          # Allow array form
          variant type: :array, of: filter_type
        end

        # Generate nested sort parameter
        definition.param :sort, type: :union, required: false do
          # Allow single sort field
          variant type: sort_type
          # Allow array of sort fields
          variant type: :array, of: sort_type
        end

        # Generate nested page parameter
        definition.param :page, type: :page_params, required: false

        # Generate nested include parameter with strict validation
        # Type includes ALL associations - contract validates structure
        include_type = generate_resource_include_type(contract_class, resource_class)
        definition.param :include, type: include_type, required: false
      end

      # Generate input contract with root key (like params.require(:service).permit(...))
      # Creates: {service: {icon: ..., name: ...}}
      def self.generate_writable_input(definition, resource_class, context)
        root_key = resource_class.root_key.singular.to_sym
        rc = resource_class
        ctx = context

        # Create nested param with root key - REQUIRED (no flat format allowed)
        definition.param root_key, type: :object, required: true do
          Generator.generate_writable_params(self, rc, ctx)
        end
      end

      def self.generate_writable_params(definition, resource_class, context)
        # Generate from writable attributes
        resource_class.attribute_definitions.each do |name, attr_def|
          next unless attr_def.writable_for?(context)

          param_options = {
            type: map_type(attr_def.type),
            required: attr_def.required? # Auto-detected from DB schema and model validations
          }

          param_options[:enum] = attr_def.enum if attr_def.enum

          definition.param name, **param_options
        end

        # Generate from writable associations
        resource_class.association_definitions.each do |name, assoc_def|
          next unless assoc_def.writable_for?(context)

          param_options = {
            type: assoc_def.singular? ? :object : :array,
            required: false, # Associations are optional by default for input
            nullable: assoc_def.nullable?
          }

          definition.param name, **param_options
        end
      end

      def self.generate_single_output(definition, resource_class)
        # Full response structure
        definition.param :ok, type: :boolean, required: true

        # Data nested under root key
        root_key = resource_class.root_key.singular.to_sym
        definition.param root_key, type: :object, required: true do
          # All resource attributes
          resource_class.attribute_definitions.each do |name, attr_def|
            param name, type: Generator.map_type(attr_def.type), required: false
          end

          # Add associations if present
          resource_class.association_definitions.each do |name, assoc_def|
            if assoc_def.singular?
              param name, type: :object, required: false, nullable: assoc_def.nullable?
            elsif assoc_def.collection?
              param name, type: :array, required: false, nullable: assoc_def.nullable?
            end
          end
        end

        # Meta is optional (only if controller adds it)
        definition.param :meta, type: :object, required: false
      end

      def self.generate_collection_output(definition, resource_class)
        # Full response structure
        definition.param :ok, type: :boolean, required: true

        # Array of items nested under root key
        root_key = resource_class.root_key.plural.to_sym
        definition.param root_key, type: :array, required: true, of: :object do
          # Each item has all resource attributes
          resource_class.attribute_definitions.each do |name, attr_def|
            param name, type: Generator.map_type(attr_def.type), required: false
          end

          # Add associations if present
          resource_class.association_definitions.each do |name, assoc_def|
            if assoc_def.singular?
              param name, type: :object, required: false, nullable: assoc_def.nullable?
            elsif assoc_def.collection?
              param name, type: :array, required: false, nullable: assoc_def.nullable?
            end
          end
        end

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

      # Define base filter types (string, date, numeric, uuid, boolean)
      def self.define_filter_types(contract_class)
        # Skip if already defined
        return if contract_class.custom_types&.key?(:string_filter)

        # String filter operators
        contract_class.type :string_filter do
          param :equal, type: :string, required: false
          param :not_equal, type: :string, required: false
          param :contains, type: :string, required: false
          param :not_contains, type: :string, required: false
          param :starts_with, type: :string, required: false
          param :ends_with, type: :string, required: false
          param :in, type: :array, of: :string, required: false
          param :not_in, type: :array, of: :string, required: false
        end

        # Date/DateTime filter operators
        contract_class.type :date_filter do
          param :equal, type: :string, required: false
          param :not_equal, type: :string, required: false
          param :greater_than, type: :string, required: false
          param :greater_than_or_equal_to, type: :string, required: false
          param :less_than, type: :string, required: false
          param :less_than_or_equal_to, type: :string, required: false
          param :between, type: :object, required: false do
            param :from, type: :string, required: true
            param :to, type: :string, required: true
          end
          param :not_between, type: :object, required: false do
            param :from, type: :string, required: true
            param :to, type: :string, required: true
          end
          param :in, type: :array, of: :string, required: false
          param :not_in, type: :array, of: :string, required: false
        end

        # Numeric filter operators (integer, decimal, float)
        contract_class.type :numeric_filter do
          param :equal, type: :integer, required: false
          param :not_equal, type: :integer, required: false
          param :greater_than, type: :integer, required: false
          param :greater_than_or_equal_to, type: :integer, required: false
          param :less_than, type: :integer, required: false
          param :less_than_or_equal_to, type: :integer, required: false
          param :between, type: :object, required: false do
            param :from, type: :integer, required: true
            param :to, type: :integer, required: true
          end
          param :not_between, type: :object, required: false do
            param :from, type: :integer, required: true
            param :to, type: :integer, required: true
          end
          param :in, type: :array, of: :integer, required: false
          param :not_in, type: :array, of: :integer, required: false
        end

        # UUID filter operators
        contract_class.type :uuid_filter do
          param :equal, type: :uuid, required: false
          param :not_equal, type: :uuid, required: false
          param :in, type: :array, of: :uuid, required: false
          param :not_in, type: :array, of: :uuid, required: false
        end

        # Boolean filter (just equality)
        contract_class.type :boolean_filter do
          param :equal, type: :boolean, required: false
        end

        # Page parameters
        contract_class.type :page_params do
          param :number, type: :integer, required: false
          param :size, type: :integer, required: false
        end
      end

      # Determine which filter type to use based on attribute type
      def self.determine_filter_type(attr_type)
        case attr_type
        when :string
          :string_filter
        when :date, :datetime
          :date_filter
        when :integer, :decimal, :float
          :numeric_filter
        when :uuid
          :uuid_filter
        when :boolean
          :boolean_filter
        else
          :string_filter # Default fallback
        end
      end

      # Generate resource-specific filter type with recursive association support
      # @param contract_class [Class] The contract class to define types on
      # @param resource_class [Class] The resource class to generate filters for
      # @param visited [Set] Set of visited resource classes (circular reference protection)
      # @param depth [Integer] Current recursion depth (max 3)
      def self.generate_resource_filter_type(contract_class, resource_class, visited: Set.new, depth: 0)
        type_name = :"#{resource_class.root_key.singular}_filter"

        # Skip if already defined or max depth reached
        return type_name if contract_class.custom_types&.key?(type_name)
        return type_name if depth >= 3

        # Add to visited set
        visited = visited.dup.add(resource_class)

        # Define the filter type
        contract_class.type type_name do
          # Add filters for each filterable attribute
          resource_class.attribute_definitions.each do |name, attr_def|
            next unless attr_def.filterable?

            filter_type = Generator.determine_filter_type(attr_def.type)

            # Support shorthand: allow primitive value OR filter object
            param name, type: :union, required: false do
              # Primitive value variant (shorthand)
              if attr_def.enum
                # If attribute has enum, pass it to the variant
                variant type: Generator.map_type(attr_def.type), enum: attr_def.enum
              else
                variant type: Generator.map_type(attr_def.type)
              end
              # Filter object variant
              variant type: filter_type
            end
          end

          # Add filters for associations (recursive)
          resource_class.association_definitions.each do |name, assoc_def|
            # Skip if circular reference
            assoc_resource = Generator.resolve_association_resource(assoc_def)
            next unless assoc_resource
            next if visited.include?(assoc_resource)

            # Recursively generate filter type for associated resource
            assoc_filter_type = Generator.generate_resource_filter_type(
              contract_class,
              assoc_resource,
              visited: visited,
              depth: depth + 1
            )

            # Add association filter parameter
            param name, type: assoc_filter_type, required: false
          end
        end

        type_name
      end

      # Generate resource-specific sort type with recursive association support
      # @param contract_class [Class] The contract class to define types on
      # @param resource_class [Class] The resource class to generate sorts for
      # @param visited [Set] Set of visited resource classes (circular reference protection)
      # @param depth [Integer] Current recursion depth (max 3)
      def self.generate_resource_sort_type(contract_class, resource_class, visited: Set.new, depth: 0)
        type_name = :"#{resource_class.root_key.singular}_sort"

        # Skip if already defined or max depth reached
        return type_name if contract_class.custom_types&.key?(type_name)
        return type_name if depth >= 3

        # Add to visited set
        visited = visited.dup.add(resource_class)

        # Define the sort type
        contract_class.type type_name do
          # Add sort for each sortable attribute
          resource_class.attribute_definitions.each do |name, attr_def|
            next unless attr_def.sortable?

            # Sort direction: asc or desc
            param name, type: :string, enum: ['asc', 'desc'], required: false
          end

          # Add sort for associations (recursive)
          resource_class.association_definitions.each do |name, assoc_def|
            # Skip if circular reference
            assoc_resource = Generator.resolve_association_resource(assoc_def)
            next unless assoc_resource
            next if visited.include?(assoc_resource)

            # Recursively generate sort type for associated resource
            assoc_sort_type = Generator.generate_resource_sort_type(
              contract_class,
              assoc_resource,
              visited: visited,
              depth: depth + 1
            )

            # Add association sort parameter
            param name, type: assoc_sort_type, required: false
          end
        end

        type_name
      end

      # Resolve the resource class from an association definition
      # @param assoc_def [AssociationDefinition] The association definition
      # @return [Class, nil] The associated resource class or nil
      def self.resolve_association_resource(assoc_def)
        # If resource_class is explicitly set, use it
        if assoc_def.resource_class
          return assoc_def.resource_class if assoc_def.resource_class.is_a?(Class)
          return assoc_def.resource_class.constantize rescue nil
        end

        # Get the model class from the resource (stored during initialization)
        model_class = assoc_def.instance_variable_get(:@model_class)
        return nil unless model_class

        # Get the ActiveRecord reflection for this association
        reflection = model_class.reflect_on_association(assoc_def.name)
        return nil unless reflection

        # Get the associated model class from the reflection
        assoc_model_class = reflection.klass rescue nil
        return nil unless assoc_model_class

        # Find the corresponding resource class
        # Convention: Model::User -> Api::V1::UserResource
        # Support nested models: Model::Nested::User -> Api::V1::UserResource
        resource_class_name = "Api::V1::#{assoc_model_class.name.demodulize}Resource"
        resource_class_name.constantize rescue nil
      end

      # Generate resource-specific include type with recursive association support
      # @param contract_class [Class] The contract class to define types on
      # @param resource_class [Class] The resource class to generate includes for
      # @param visited [Set] Set of visited resource classes (circular reference protection)
      # @param depth [Integer] Current recursion depth (max 3)
      def self.generate_resource_include_type(contract_class, resource_class, visited: Set.new, depth: 0)
        type_name = :"#{resource_class.root_key.singular}_include"

        # Skip if already defined or max depth reached
        return type_name if contract_class.custom_types&.key?(type_name)
        return type_name if depth >= 3

        # Add to visited set
        visited = visited.dup.add(resource_class)

        # Define the include type with ALL associations for strict validation
        # Contract validates structure, Resource applies validated includes
        contract_class.type type_name do
          resource_class.association_definitions.each do |name, assoc_def|
            assoc_resource = Generator.resolve_association_resource(assoc_def)
            next unless assoc_resource

            # For circular references, still allow the association but don't recurse
            # This allows includes like { comments: { post: true } } where post→comments and comments→post
            if visited.include?(assoc_resource)
              # Just allow boolean variant for circular refs (can't nest further)
              param name, type: :boolean, required: false
            else
              # Recursively generate include type for associated resource
              assoc_include_type = Generator.generate_resource_include_type(
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
