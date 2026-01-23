# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Envelope
        class Base
          attr_reader :document_type, :options, :schema_class

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

          def initialize(context)
            @document_type = context.document_type
            @schema_class = context.schema_class
            @options = context.options
            @target = context.target
          end

          def build
            raise NotImplementedError
          end

          def collection?
            document_type == :collection
          end

          def record?
            document_type == :record
          end

          private

          attr_reader :target
        end
      end
    end
  end
end
