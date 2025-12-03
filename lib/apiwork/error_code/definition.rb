# frozen_string_literal: true

module Apiwork
  module ErrorCode
    Definition = Struct.new(:key, :status, keyword_init: true)
  end
end
