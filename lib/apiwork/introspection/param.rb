# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class << self
        def build(dump)
          case dump[:type]
          when :string then String.new(dump)
          when :integer then Integer.new(dump)
          when :float then Float.new(dump)
          when :decimal then Decimal.new(dump)
          when :boolean then Boolean.new(dump)
          when :datetime then DateTime.new(dump)
          when :date then Date.new(dump)
          when :time then Time.zone.local(dump)
          when :uuid then UUID.new(dump)
          when :binary then Binary.new(dump)
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
