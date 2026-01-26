# frozen_string_literal: true

module Api
  module OverrideTest
    class ArticleContract < Apiwork::Contract::Base
      representation ArticleRepresentation
    end
  end
end
