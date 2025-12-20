# frozen_string_literal: true

module Apiwork
  # @api public
  module Controller
    extend ActiveSupport::Concern

    include Deserialization
    include Resolution
    include Serialization
  end
end
