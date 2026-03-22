# frozen_string_literal: true

module Apiwork
  module Export
    class Sorbus < Base
      export_name :sorbus
      output :string
      file_extension '.ts'

      option :builders, default: false, type: :boolean

      def generate
        output = SorbusMapper.map(self, surface)
        output += "\n\n#{BuilderMapper.map(self, surface)}" if options[:builders]
        output
      end

      private

      def surface
        @surface ||= SurfaceResolver.resolve(api)
      end
    end
  end
end
