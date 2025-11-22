# frozen_string_literal: true

module Api
  module OverrideTest
    class ArticleContract < Apiwork::Contract::Base
      schema ArticleSchema
    end
  end
end
