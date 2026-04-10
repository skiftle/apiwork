# frozen_string_literal: true

module Apiwork
  module Export
    class Zod < Base
      export_name :zod
      output :string
      file_extension '.ts'

      option :version, default: '4', enum: %w[4], type: :string

      def generate
        parts = []

        parts << "import { z } from 'zod';\n"

        zod_schemas = ZodMapper.map(self, surface)
        if zod_schemas.present?
          parts << zod_schemas
          parts << ''
        end

        typescript_types = TypeScriptMapper.map(self, surface)
        if typescript_types.present?
          parts << typescript_types
          parts << ''
        end

        parts.join("\n")
      end

      private

      def surface
        @surface ||= SurfaceResolver.resolve(api)
      end
    end
  end
end
