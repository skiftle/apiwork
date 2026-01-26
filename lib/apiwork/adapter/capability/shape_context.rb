# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class ShapeContext
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

        def initialize(options:, representation_class:, target:)
          @options = options
          @representation_class = representation_class
          @target = target
        end

        private

        attr_reader :target
      end
    end
  end
end
