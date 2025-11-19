# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Descriptor Builder' do
  before do
    Apiwork.reset_registries!
  end

  after do
    Apiwork.reset_registries!
  end

  it 'allows defining types via descriptors block' do
    api = Apiwork::API.draw '/api/test' do
      descriptors do
        type :error do
          param :error, type: :string
          param :code, type: :integer
        end
      end
    end

    types = Apiwork::Contract::Descriptor::Registry.types(api)

    expect(types).to have_key(:error)
    expect(types[:error]).to eq(
      error: { type: :string, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil, max: nil },
      code: { type: :integer, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil, max: nil }
    )
  end

  it 'allows defining enums via descriptors block' do
    api = Apiwork::API.draw '/api/test' do
      descriptors do
        enum :sort_direction, %i[asc desc]
      end
    end

    enums = Apiwork::Contract::Descriptor::Registry.enums(api)

    expect(enums).to have_key(:sort_direction)
    expect(enums[:sort_direction]).to eq(%i[asc desc])
  end

  it 'auto-generates enum filter types for enums defined via descriptors' do
    api = Apiwork::API.draw '/api/test' do
      descriptors do
        enum :status, %i[active inactive pending]
      end
    end

    types = Apiwork::Contract::Descriptor::Registry.types(api)

    expect(types).to have_key(:status_filter)
    expect(types[:status_filter][:type]).to eq(:union)
    expect(types[:status_filter][:variants].size).to eq(2)
  end

  it 'registers descriptors as unprefixed (API-global)' do
    api = Apiwork::API.draw '/api/test' do
      descriptors do
        type :global_type do
          param :value, type: :string
        end
      end
    end

    types = Apiwork::Contract::Descriptor::Registry.types(api)

    # Should be registered as :global_type, not qualified with any contract prefix
    expect(types).to have_key(:global_type)
    expect(types).not_to have_key(:test_global_type)
  end

  it 'allows multiple descriptors blocks' do
    api = Apiwork::API.draw '/api/test' do
      descriptors do
        type :error do
          param :message, type: :string
        end
      end

      descriptors do
        enum :priority, %i[low medium high]
      end
    end

    types = Apiwork::Contract::Descriptor::Registry.types(api)
    enums = Apiwork::Contract::Descriptor::Registry.enums(api)

    expect(types).to have_key(:error)
    expect(enums).to have_key(:priority)
  end
end
