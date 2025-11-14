# frozen_string_literal: true

module Apiwork
  class ValidationError < ConstraintError
    def self.from_rails_error(rails_error, path: [])
      meta = { attribute: rails_error.attribute }

      if rails_error.options
        %i[in minimum maximum count is too_short too_long].each do |key|
          value = rails_error.options[key]
          meta[key] = value if value
        end
      end

      new(
        code: rails_error.type,
        message: rails_error.message,
        path: path,
        meta: meta
      )
    end
  end
end
