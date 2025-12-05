# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      AssociationResource = Struct.new(:schema, :sti, keyword_init: true) do
        def sti?
          sti == true
        end

        def self.polymorphic
          :polymorphic
        end

        def self.for(schema, sti: false)
          new(schema:, sti:)
        end
      end
    end
  end
end
