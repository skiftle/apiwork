# frozen_string_literal: true

module Apiwork
  module Registrable
    def identifier(name = nil)
      @identifier = name.to_sym if name
      @identifier
    end
  end
end
