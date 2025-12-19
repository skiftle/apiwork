# frozen_string_literal: true

module Apiwork
  module Controller
    extend ActiveSupport::Concern

    include Resolution
    include Deserialization
    include Serialization
  end
end
