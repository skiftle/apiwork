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
    expect(types[:error]).to include(
      type: :object,
      shape: {
        error: { type: :string, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil,
                 max: nil },
        code: { type: :integer, required: false, nullable: false, description: nil, example: nil, format: nil, deprecated: false, min: nil, max: nil }
      },
      description: nil,
      example: nil,
      format: nil,
      deprecated: false
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
    expect(enums[:sort_direction][:values]).to eq(%i[asc desc])
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

  describe 'Metadata support' do
    it 'allows defining type with description' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :documented_type, description: 'A type with description' do
            param :field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:documented_type]).to include(description: 'A type with description')
    end

    it 'allows defining type with example' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :example_type, example: { field: 'value' } do
            param :field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:example_type]).to include(example: { field: 'value' })
    end

    it 'allows defining type with format' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :formatted_type, format: 'email' do
            param :email, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:formatted_type]).to include(format: 'email')
    end

    it 'allows defining type with deprecated: true' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :legacy_type, deprecated: true do
            param :old_field, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:legacy_type]).to include(deprecated: true)
    end

    it 'allows defining type with all metadata fields' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :full_metadata_type,
               description: 'Comprehensive metadata',
               example: { data: 'example' },
               format: 'custom',
               deprecated: false do
            param :data, type: :string
          end
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)

      expect(types[:full_metadata_type]).to include(
        description: 'Comprehensive metadata',
        example: { data: 'example' },
        format: 'custom',
        deprecated: false
      )
    end

    it 'allows defining enum with description' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :documented_enum, %i[a b c], description: 'An enum with description'
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:documented_enum]).to include(description: 'An enum with description')
    end

    it 'allows defining enum with example' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :example_enum, %i[red green blue], example: :red
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:example_enum]).to include(example: :red)
    end

    it 'allows defining enum with deprecated: true' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :legacy_enum, %i[old new], deprecated: true
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:legacy_enum]).to include(deprecated: true)
    end

    it 'allows defining enum with all metadata fields' do
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          enum :full_metadata_enum,
               %w[option1 option2],
               description: 'Complete enum metadata',
               example: 'option1',
               deprecated: false
        end
      end

      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      expect(enums[:full_metadata_enum]).to eq(
        values: %w[option1 option2],
        description: 'Complete enum metadata',
        example: 'option1',
        deprecated: false
      )
    end

    it 'passes metadata through to Registry' do
      # This test verifies the integration between Builder and Registry
      api = Apiwork::API.draw '/api/test' do
        descriptors do
          type :chained_type, description: 'Metadata flows through' do
            param :value, type: :string
          end

          enum :chained_enum, %i[x y], description: 'Enum metadata flows through'
        end
      end

      types = Apiwork::Contract::Descriptor::Registry.types(api)
      enums = Apiwork::Contract::Descriptor::Registry.enums(api)

      # Verify metadata is preserved through the chain
      expect(types[:chained_type][:description]).to eq('Metadata flows through')
      expect(enums[:chained_enum][:description]).to eq('Enum metadata flows through')
    end
  end
end
