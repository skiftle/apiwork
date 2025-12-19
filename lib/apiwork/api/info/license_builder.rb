# frozen_string_literal: true

module Apiwork
  module API
    module Info
      # @api private
      class LicenseBuilder
        attr_reader :data

        def initialize
          @data = {}
        end

        def name(text)
          @data[:name] = text
        end

        def url(text)
          @data[:url] = text
        end
      end
    end
  end
end
