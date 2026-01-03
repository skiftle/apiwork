# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Namespace for parameter/field definitions.
    #
    # Params are accessed via introspection - you never create them directly.
    # Use `Param.build(dump)` to create a param from a dump hash.
    #
    # @example Accessing params via introspection
    #   api = Apiwork::Introspection::API.new(MyApi)
    #   action = api.resources[:invoices].actions[:show]
    #   param = action.request.query[:page]
    #   param.type         # => :integer
    #   param.optional?    # => true
    #
    # @example Type-specific subclasses
    #   param = action.response.body  # => Param::Array
    #   param.of                      # => Param::Object (element type)
    module Param
      class << self
        def build(dump)
          if dump[:enum]
            return dump[:enum].is_a?(::Array) ? Scalar::Enum::Inline.new(dump) : Scalar::Enum::Ref.new(dump)
          end

          case dump[:type]
          when :string then Scalar::String.new(dump)
          when :integer then Scalar::Numeric::Integer.new(dump)
          when :float then Scalar::Numeric::Float.new(dump)
          when :decimal then Scalar::Numeric::Decimal.new(dump)
          when :boolean then Scalar::Boolean.new(dump)
          when :datetime then Scalar::DateTime.new(dump)
          when :date then Scalar::Date.new(dump)
          when :time then Scalar::Time.new(dump)
          when :uuid then Scalar::UUID.new(dump)
          when :binary then Scalar::Binary.new(dump)
          when :json then Json.new(dump)
          when :unknown then Unknown.new(dump)
          when :array then Array.new(dump)
          when :object then Object.new(dump)
          when :union then Union.new(dump)
          when :literal then Literal.new(dump)
          when Symbol then RefType.new(dump)
          else Unknown.new(dump)
          end
        end
      end
    end
  end
end
