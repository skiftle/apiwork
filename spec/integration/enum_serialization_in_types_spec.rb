# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Enum serialization in custom types', type: :integration do
  before(:all) do
    Object.send(:remove_const, :TestEnumSerializationContract) if defined?(TestEnumSerializationContract)

    class TestEnumSerializationContract < Apiwork::Contract::Base
      action :archive do
        enum :hahahehe, %w[asc desc]

        type :hehe do
          param :equal, type: :string, required: false, enum: :hahahehe
          param :contains, type: :string, required: false
        end

        input do
          param :filter, type: :hehe, required: false
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestEnumSerializationContract) if defined?(TestEnumSerializationContract)
  end

  it 'serializes type with correctly qualified enum reference' do
    all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
    hehe_type = all_types[:test_enum_serialization_archive_hehe]

    expect(hehe_type).to be_a(Hash)
    expect(hehe_type[:equal]).to be_a(Hash)
    expect(hehe_type[:equal][:enum]).to eq(:test_enum_serialization_archive_hahahehe)
  end
end
