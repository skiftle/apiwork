# frozen_string_literal: true

module Apiwork
  module Introspection
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
          when :json then JSON.new(dump)
          when :unknown then Unknown.new(dump)
          when :array then Array.new(dump)
          when :object then Object.new(dump)
          when :union then Union.new(dump)
          when :literal then Literal.new(dump)
          when :ref then Ref.new(dump)
          else Unknown.new(dump)
          end
        end
      end
    end
  end
end
