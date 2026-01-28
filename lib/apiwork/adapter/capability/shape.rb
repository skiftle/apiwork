# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Shape
        attr_reader :options

        delegate :array,
                 :array?,
                 :binary,
                 :binary?,
                 :boolean,
                 :boolean?,
                 :date,
                 :date?,
                 :datetime,
                 :datetime?,
                 :decimal,
                 :decimal?,
                 :integer,
                 :integer?,
                 :literal,
                 :merge!,
                 :number,
                 :number?,
                 :object,
                 :object?,
                 :reference,
                 :reference?,
                 :string,
                 :string?,
                 :time,
                 :time?,
                 :union,
                 :union?,
                 :uuid,
                 :uuid?,
                 to: :object

        def initialize(object, options)
          @object = object
          @options = options
        end

        private

        attr_reader :object
      end
    end
  end
end
