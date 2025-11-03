# frozen_string_literal: true

RSpec.describe Apiwork do
  it 'has a version number' do
    expect(Apiwork::VERSION).not_to be nil
  end

  it 'can be configured' do
    Apiwork.configure do |config|
      config.default_page_size = 25
    end
    expect(Apiwork.configuration.default_page_size).to eq(25)
  end
end
