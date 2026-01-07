# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ConfigurationError do
  it 'inherits from Error' do
    expect(described_class.superclass).to eq(Apiwork::Error)
  end

  it 'can be raised with a message' do
    expect { raise described_class, 'Invalid configuration' }.to raise_error(
      described_class, 'Invalid configuration'
    )
  end
end
