# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class DomainIssueMapper
        class CodeNormalizer
          CODE_MAP = {
            blank: :required,
            present: :forbidden,
            empty: :required,
            taken: :unique,
            accepted: :accepted,
            confirmation: :confirmed,
            too_short: :min,
            too_long: :max,
            wrong_length: :length,
            not_a_number: :number,
            not_an_integer: :integer,
            greater_than: :gt,
            greater_than_or_equal_to: :gte,
            less_than: :lt,
            less_than_or_equal_to: :lte,
            equal_to: :eq,
            other_than: :ne,
            odd: :odd,
            even: :even,
            inclusion: :in,
            exclusion: :not_in,
            in: :in,
            invalid: :invalid,
            restrict_dependent_destroy: :associated
          }.freeze

          def self.call(error, record)
            new(error, record).call
          end

          def initialize(error, record)
            @error = error
            @record = record
          end

          def call
            return :invalid if base_error?

            normalized = CODE_MAP[@error.type]
            return normalized if normalized

            :custom
          end

          private

          def base_error?
            @error.attribute == :base
          end
        end
      end
    end
  end
end
