# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      AssociationResource = Struct.new(:schema_class, :sti, keyword_init: true) do
        def sti?
          sti
        end

        def self.polymorphic
          :polymorphic
        end

        def self.for(schema_class, sti: false)
          new(schema_class:, sti:)
        end
      end
    end
  end
end
