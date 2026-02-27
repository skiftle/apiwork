# frozen_string_literal: true

module Apiwork
  module Export
    class Sorbus < Base
      export_name :sorbus
      output :string
      file_extension '.ts'

      def generate
        SorbusMapper.map(self, surface)
      end

      private

      def surface
        @surface ||= SurfaceResolver.resolve(api)
      end
    end
  end
end
