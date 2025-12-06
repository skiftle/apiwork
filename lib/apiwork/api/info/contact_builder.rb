# frozen_string_literal: true

module Apiwork
  module API
    module Info
      class Builder
        class ContactBuilder
          attr_reader :data

          def initialize
            @data = {}
          end

          def name(text)
            @data[:name] = text
          end

          def email(text)
            @data[:email] = text
          end

          def url(text)
            @data[:url] = text
          end
        end
      end
    end
  end
end
