# frozen_string_literal: true

module ApiTestHelper
  TEST_API_PATH = '/api/test'

  def self.api_class
    existing = Apiwork::API.find(TEST_API_PATH)
    return existing if existing

    create_test_api
  end

  def self.create_test_api
    Apiwork::API.define TEST_API_PATH do
      resources :tests
    end
  end

  def create_test_contract(&block)
    contract_class = Class.new(Apiwork::Contract::Base)
    contract_class.instance_variable_set(:@api_class, ApiTestHelper.api_class)
    contract_class.class_eval(&block) if block_given?
    contract_class
  end
end

RSpec.configure do |config|
  config.include ApiTestHelper
end
