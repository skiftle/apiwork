# frozen_string_literal: true

module EagerLion
  class CustomerSchema < Apiwork::Schema::Base
    attribute :id
    attribute :name
  end
end
