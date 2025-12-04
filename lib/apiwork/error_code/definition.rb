# frozen_string_literal: true

module Apiwork
  module ErrorCode
    Definition = Struct.new(:key, :status, :attach_path, keyword_init: true) do
      def attach_path?
        attach_path == true
      end
    end
  end
end
