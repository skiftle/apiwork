# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class TypeMapper
        class << self
          def map(type)
            case type
            when :string, :text then :string
            when :integer then :integer
            when :boolean then :boolean
            when :datetime then :datetime
            when :date then :date
            when :time then :time
            when :uuid then :uuid
            when :decimal, :number then :decimal
            when :object then :object
            when :array then :array
            else :unknown
            end
          end
        end
      end
    end
  end
end
