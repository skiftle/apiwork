# frozen_string_literal: true

module Apiwork
  module Export
    class Apiwork < Base
      export_name :apiwork
      output :hash

      def generate
        ApiworkMapper.map(self, surface)
      end

      private

      def surface
        @surface ||= SurfaceResolver.resolve(api)
      end
    end
  end
end
