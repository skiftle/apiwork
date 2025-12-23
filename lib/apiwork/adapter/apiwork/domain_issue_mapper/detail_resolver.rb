# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class DomainIssueMapper
        class DetailResolver
          DETAIL_MAP = {
            required: 'Required',
            forbidden: 'Must be blank',
            unique: 'Already taken',
            format: 'Invalid format',
            accepted: 'Must be accepted',
            confirmed: 'Does not match',
            min: 'Too short',
            max: 'Too long',
            length: 'Wrong length',
            number: 'Not a number',
            integer: 'Not an integer',
            gt: 'Too small',
            gte: 'Too small',
            lt: 'Too large',
            lte: 'Too large',
            eq: 'Wrong value',
            ne: 'Reserved value',
            odd: 'Must be odd',
            even: 'Must be even',
            in: 'Invalid value',
            not_in: 'Reserved value',
            associated: 'Invalid',
            invalid: 'Invalid',
            custom: 'Validation failed'
          }.freeze

          def self.detail_for(code)
            DETAIL_MAP[code] || DETAIL_MAP[:custom]
          end
        end
      end
    end
  end
end
