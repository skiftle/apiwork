# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adapter configuration validation', type: :integration do
  it 'rejects invalid key_format' do
    expect do
      Apiwork::API.define '/integration/configuration-invalid-key-format' do
        key_format :invalid_strategy
      end
    end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
  end

  it 'rejects non-integer pagination size' do
    expect do
      Apiwork::API.define '/integration/configuration-invalid-page-size' do
        adapter do
          pagination do
            default_size 'not_an_integer'
          end
        end
      end
    end.to raise_error(Apiwork::ConfigurationError, /must be integer/)
  end

  it 'rejects unknown adapter options' do
    expect do
      Apiwork::API.define '/integration/configuration-unknown-adapter-option' do
        adapter do
          unknown_option 'value'
        end
      end
    end.to raise_error(Apiwork::ConfigurationError, /Unknown option/)
  end
end
