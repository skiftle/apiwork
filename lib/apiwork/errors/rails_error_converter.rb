# frozen_string_literal: true

module Apiwork
  module Errors
    # Converts Rails ActiveModel::Errors to structured error arrays
    #
    # This class converts Rails model validation errors into StructuredError objects
    # with proper path tracking and JSON Pointers. It handles nested associations
    # recursively and reuses Rails error type symbols as error codes.
    #
    # The root path is determined by the schema_class root_key:
    # - If root_key == :data → path: [:data, :name]
    # - If root_key == :type → path: [:comment, :name] (uses model singular name)
    #
    # Examples:
    #   converter = RailsErrorConverter.new(client, schema_class: ClientSchema)
    #   errors = converter.convert
    #   # => [
    #   #   StructuredError(code: :blank, path: [:data, :name], detail: "Name can't be blank"),
    #   #   StructuredError(code: :inclusion, path: [:data, :address, :country_code], ...)
    #   # ]
    class RailsErrorConverter
      def initialize(record, schema_class: nil, resource_class: nil, root_path: nil)
        @record = record
        @schema_class = schema_class || resource_class # Support legacy resource_class param

        # Determine root path based on schema_class root_key
        @root_path = if root_path
                       Array(root_path)
                     elsif @schema_class
                       build_root_path_from_schema_class(@schema_class)
                     else
                       [:data] # Default fallback
                     end
      end

      # Convert all errors to StructuredError array
      #
      # @return [Array<StructuredError>] Array of structured errors
      def convert
        return [] unless @record.respond_to?(:errors)

        errors = []
        errors.concat(convert_direct_errors)
        errors.concat(convert_association_errors)
        errors
      end

      private

      # Build root path from schema_class
      def build_root_path_from_schema_class(schema_class)
        type_key = schema_class.root_key.singular
        [type_key.to_sym]
      end

      # Legacy method name (deprecated)
      alias build_root_path_from_resource_class build_root_path_from_schema_class

      # Convert direct errors on the record
      # Excludes nested association errors (those with dots like "address.country_code")
      # because they're handled recursively via convert_association_errors
      def convert_direct_errors
        return [] unless @record.errors.any?

        @record.errors.map do |error|
          # Skip nested attribute errors (e.g., "address.country_code")
          # These are handled by convert_association_errors recursively
          next if error.attribute.to_s.include?('.')

          # For belongs_to associations, convert :association to :association_id in path
          attribute_name = if belongs_to_association?(error.attribute)
                             "#{error.attribute}_id".to_sym
                           else
                             error.attribute
                           end

          path = [@root_path, attribute_name].flatten

          StructuredError.for_rails_validation(error, path: path)
        end.compact
      end

      # Convert errors from nested associations
      def convert_association_errors
        errors = []
        errors.concat(convert_has_many_errors)
        errors.concat(convert_has_one_errors)
        errors
      end

      # Convert errors from has_many associations
      def convert_has_many_errors
        errors = []

        @record.class.reflect_on_all_associations(:has_many).each do |association|
          associated_records = @record.send(association.name)
          next unless associated_records.respond_to?(:each)
          next unless associated_records.any?

          associated_records.each_with_index do |associated_record, index|
            next unless associated_record.respond_to?(:errors)
            next unless associated_record.errors.any?

            # Build path for this association item: [:data, :sites, 0]
            association_path = [@root_path, association.name, index].flatten

            # Recursively convert errors - pass down resource_class context
            converter = self.class.new(associated_record, root_path: association_path)
            errors.concat(converter.convert)
          end
        end

        errors
      end

      # Convert errors from has_one associations
      def convert_has_one_errors
        errors = []

        @record.class.reflect_on_all_associations(:has_one).each do |association|
          associated_record = @record.send(association.name)
          next unless associated_record
          next unless associated_record.respond_to?(:errors)
          next unless associated_record.errors.any?

          # Build path for this association: [:data, :address]
          association_path = [@root_path, association.name].flatten

          # Recursively convert errors - pass down resource_class context
          converter = self.class.new(associated_record, root_path: association_path)
          errors.concat(converter.convert)
        end

        errors
      end

      # Check if attribute is a belongs_to association
      def belongs_to_association?(attribute)
        @record.class.reflect_on_all_associations(:belongs_to)
               .map(&:name)
               .include?(attribute)
      end
    end
  end
end
