# frozen_string_literal: true

module Apiwork
  module Configuration
    class Option
      include Validatable

      attr_reader :children,
                  :default,
                  :enum,
                  :name,
                  :type

      def initialize(name, type, default: nil, enum: nil, &block)
        @name = name
        @type = type
        @default = default
        @enum = enum
        @children = {}

        instance_eval(&block) if block && type == :hash
      end

      def option(name, default:, enum: nil, type:)
        @children[name] = NestedOption.new(name, type, default, enum:)
      end

      def nested?
        children.any?
      end

      def resolved_default
        return default unless nested?

        children.transform_values(&:default)
      end

      def validate!(value)
        return if value.nil?

        if nested?
          raise ConfigurationError, "#{name} must be a Hash" unless value.is_a?(Hash)

          validate_children!(value)
        else
          validate_type!(value)
          validate_enum!(value) if enum
        end
      end

      def cast(value)
        return nil if value.nil?
        return value unless value.is_a?(String)

        case type
        when :symbol then value.to_sym
        when :string then value
        when :integer then value.to_i
        when :boolean then %w[true 1 yes].include?(value.downcase)
        when :hash then value
        end
      end

      private

      def validate_children!(hash)
        hash.each do |key, value|
          child = children[key]
          raise ConfigurationError, "Unknown option: #{name}.#{key}" unless child

          child.validate!(value)
        end
      end
    end
  end
end
