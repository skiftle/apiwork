# frozen_string_literal: true

module Apiwork
  module Export
    class TypeScript < Base
      export_name :typescript
      output :string
      file_extension '.ts'

      option :version, default: '5', enum: %w[4 5], type: :string

      def generate
        mapper.generate(surface)
      end

      private

      def surface
        @surface ||= SurfaceResolver.new(api)
      end

      def mapper
        @mapper ||= TypeScriptMapper.new(self)
      end
    end
  end
end
