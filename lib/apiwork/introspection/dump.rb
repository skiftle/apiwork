# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class << self
        def api(api_class)
          API.new(api_class).to_h
        end

        def contract(contract_class, expand: false)
          Contract.new(contract_class, expand:).to_h
        end
      end
    end
  end
end
