# frozen_string_literal: true

module TestApiHelper
  TEST_API_PATH = '/api/test'

  def self.api_class
    @api_class ||= create_test_api
  end

  def self.create_test_api
    Apiwork::API.define TEST_API_PATH do
      resources :tests
    end
  end

  def self.reset!
    @api_class = nil
    Apiwork::API::Registry.unregister(TEST_API_PATH)
  end

  def create_test_contract(&block)
    contract_class = Class.new(Apiwork::Contract::Base)
    contract_class.instance_variable_set(:@api_class, TestApiHelper.api_class)
    contract_class.class_eval(&block) if block_given?
    contract_class
  end
end

RSpec.configure do |config|
  config.include TestApiHelper

  config.before(:suite) do
    TestApiHelper.api_class
  end
end
