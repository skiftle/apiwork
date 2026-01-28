# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Shape
        attr_reader :options, :representation_class

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
                 to: :target

        def initialize(target, representation_class, options)
          @target = target
          @representation_class = representation_class
          @options = options
        end

        private

        attr_reader :target
      end
    end
  end
end
