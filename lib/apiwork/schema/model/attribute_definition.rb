# frozen_string_literal: true

module Apiwork
  module Schema
    module Model
      # AttributeDefinition - Model-specific attribute definition with ActiveRecord auto-detection
      # Inherits from Schema::AttributeDefinition and adds DB column introspection
      class AttributeDefinition < Apiwork::Schema::AttributeDefinition
        def initialize(name, klass:, **options)
          @model_class = klass.model_class
          @is_db_column = @model_class&.column_names&.include?(name.to_s)

          # Auto-detect enum values if not provided
          options[:enum] ||= detect_enum_values(name)

          # Auto-detect type from DB column if not provided
          options[:type] ||= detect_type(name) if @is_db_column

          # Auto-detect required if not specified
          options[:required] = auto_detect_required(name, options) if options[:required].nil? && @is_db_column

          # Call parent with enhanced options
          super(name, klass: klass, **options)
        end

        # Override: validate_attribute_exists! to include model checks
        def validate_attribute_exists!
          return if @klass.abstract_class

          # Check model first (DB column or model method)
          if @is_db_column || @model_class&.instance_methods&.include?(@name.to_sym)
            return
          end

          # Check resource methods
          return if @klass.instance_methods.include?(@name.to_sym)

          # Attribute not found
          detail = "Undefined resource attribute '#{@name}' in #{@klass.send(:name_of_self)}: " \
                   'no DB column, no reader method on model, and no reader method on resource'
          error = Apiwork::ConfigurationError.new(
            code: :invalid_attribute,
            detail: detail,
            path: [@name]
          )

          Apiwork::Errors::Handler.handle(error, context: { attribute: @name, resource: @klass.send(:name_of_self) })
        end

        private

        def detect_enum_values(name)
          return nil unless @model_class&.defined_enums&.key?(name.to_s)

          @model_class.defined_enums[name.to_s].keys
        end

        def detect_type(name)
          @model_class.type_for_attribute(name).type
        end

        def auto_detect_required(name, options)
          return false unless @model_class
          return false unless @is_db_column

          column = @model_class.columns_hash[name.to_s]

          # If column has a default value AND it's not an enum, it's not required from API perspective
          # (database will handle it automatically)
          # Exception: Enum fields with defaults are still required because Rails doesn't apply
          # the default in memory, and enum validators reject nil
          return false if column&.default.present? && !@model_class.defined_enums.key?(name.to_s)

          # Check DB constraint: null: false means required
          true unless column&.null
        end
      end
    end
  end
end
