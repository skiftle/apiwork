# frozen_string_literal: true

module Apiwork
  module Controller
    # Converts ActiveModel validation errors to Issue arrays
    #
    # This class converts Rails model validation errors into Issue objects
    # with proper path tracking and JSON Pointers. It handles nested associations
    # recursively and reuses Rails error type symbols as error codes.
    #
    # The root path is determined by the schema_class root_key:
    # - If root_key == :data → path: [:data, :name]
    # - If root_key == :type → path: [:comment, :name] (uses model singular name)
    #
    # Examples:
    #   adapter = Controller::ValidationAdapter.new(client, schema_class: ClientSchema)
    #   errors = adapter.convert
    #   # => [
    #   #   Issue(code: :blank, path: [:data, :name], message: "Name can't be blank"),
    #   #   Issue(code: :inclusion, path: [:data, :address, :country_code], ...)
    #   # ]
    class ValidationAdapter
      def initialize(record, schema_class: nil, root_path: nil)
        @record = record
        @schema_class = schema_class

        # Determine root path based on schema_class root_key
        @root_path = if root_path
                       Array(root_path)
                     elsif @schema_class
                       build_root_path(@schema_class)
                     else
                       [:data] # Default fallback
                     end
      end

      def convert
        return [] unless @record.respond_to?(:errors)

        errors = []
        errors.concat(convert_attribute_errors)
        errors.concat(convert_association_errors_of_type(:has_many))
        errors.concat(convert_association_errors_of_type(:has_one))
        errors
      end

      private

      # Build root path from schema_class
      def build_root_path(schema_class)
        type_key = schema_class.root_key.singular
        [type_key.to_sym]
      end

      # Convert direct errors on the record
      # Excludes nested association errors (those with dots like "address.country_code")
      # because they're handled recursively via convert_association_errors_of_type
      def convert_attribute_errors
        return [] unless @record.errors.any?

        @record.errors.filter_map do |error|
          # Skip nested attribute errors (e.g., "address.country_code")
          # These are handled by convert_association_errors_of_type recursively
          next if error.attribute.to_s.include?('.')

          # For belongs_to associations, convert :association to :association_id in path
          attribute_name = if belongs_to?(error.attribute)
                             "#{error.attribute}_id".to_sym
                           else
                             error.attribute
                           end

          path = [@root_path, attribute_name].flatten

          issue(error, path: path)
        end
      end

      # Convert errors from associations (has_many or has_one)
      def convert_association_errors_of_type(association_type)
        errors = []

        @record.class.reflect_on_all_associations(association_type).each do |association|
          associated = @record.send(association.name)

          # Normalize to array for unified handling
          items = if association_type == :has_many
                    next unless associated.respond_to?(:each)
                    next unless associated.any?

                    associated
                  else
                    next unless associated

                    [associated]
                  end

          items.each_with_index do |item, index|
            next unless item.respond_to?(:errors)
            next unless item.errors.any?

            # Build path: has_many uses index, has_one doesn't
            association_path = if association_type == :has_many
                                 [@root_path, association.name, index].flatten
                               else
                                 [@root_path, association.name].flatten
                               end

            # Recursively convert errors
            converter = self.class.new(item, root_path: association_path)
            errors.concat(converter.convert)
          end
        end

        errors
      end

      # Check if attribute is a belongs_to association
      def belongs_to?(attribute)
        @record.class.reflect_on_all_associations(:belongs_to)
               .map(&:name)
               .include?(attribute)
      end

      # Build Issue from Rails ActiveModel error
      def issue(rails_error, path:)
        meta = { attribute: rails_error.attribute }

        if rails_error.options
          %i[in minimum maximum count is too_short too_long].each do |key|
            value = rails_error.options[key]
            meta[key] = value if value
          end
        end

        Issue.new(
          code: rails_error.type,
          message: rails_error.message,
          path: path,
          meta: meta
        )
      end
    end
  end
end
