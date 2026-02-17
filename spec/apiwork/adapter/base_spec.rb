# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Base do
  describe '.adapter_name' do
    it 'returns the adapter name' do
      adapter_class = Class.new(described_class) do
        adapter_name :billing
      end

      expect(adapter_class.adapter_name).to eq(:billing)
    end

    it 'returns nil when not set' do
      adapter_class = Class.new(described_class)

      expect(adapter_class.adapter_name).to be_nil
    end
  end

  describe '.capability' do
    it 'registers the capability' do
      capability_class = Class.new(Apiwork::Adapter::Capability::Base) do
        capability_name :unit_test_cap
      end
      adapter_class = Class.new(described_class) do
        capability capability_class
      end

      expect(adapter_class.capabilities).to include(capability_class)
    end
  end

  describe '.collection_wrapper' do
    it 'sets the collection wrapper' do
      adapter_class = Class.new(described_class) do
        collection_wrapper Apiwork::Adapter::Wrapper::Collection::Default
      end

      expect(adapter_class.collection_wrapper).to eq(Apiwork::Adapter::Wrapper::Collection::Default)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          collection_wrapper 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be a Wrapper class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          collection_wrapper String
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end

    it 'inherits from superclass' do
      parent = Class.new(described_class) do
        collection_wrapper Apiwork::Adapter::Wrapper::Collection::Default
      end
      child = Class.new(parent)

      expect(child.collection_wrapper).to eq(Apiwork::Adapter::Wrapper::Collection::Default)
    end
  end

  describe '.error_serializer' do
    it 'sets the error serializer' do
      adapter_class = Class.new(described_class) do
        error_serializer Apiwork::Adapter::Serializer::Error::Default
      end

      expect(adapter_class.error_serializer).to eq(Apiwork::Adapter::Serializer::Error::Default)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          error_serializer 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be a Serializer class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          error_serializer String
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end

    it 'inherits from superclass' do
      parent = Class.new(described_class) do
        error_serializer Apiwork::Adapter::Serializer::Error::Default
      end
      child = Class.new(parent)

      expect(child.error_serializer).to eq(Apiwork::Adapter::Serializer::Error::Default)
    end
  end

  describe '.error_wrapper' do
    it 'sets the error wrapper' do
      adapter_class = Class.new(described_class) do
        error_wrapper Apiwork::Adapter::Wrapper::Error::Default
      end

      expect(adapter_class.error_wrapper).to eq(Apiwork::Adapter::Wrapper::Error::Default)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          error_wrapper 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be a Wrapper class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          error_wrapper String
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end

    it 'inherits from superclass' do
      parent = Class.new(described_class) do
        error_wrapper Apiwork::Adapter::Wrapper::Error::Default
      end
      child = Class.new(parent)

      expect(child.error_wrapper).to eq(Apiwork::Adapter::Wrapper::Error::Default)
    end
  end

  describe '.member_wrapper' do
    it 'sets the member wrapper' do
      adapter_class = Class.new(described_class) do
        member_wrapper Apiwork::Adapter::Wrapper::Member::Default
      end

      expect(adapter_class.member_wrapper).to eq(Apiwork::Adapter::Wrapper::Member::Default)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          member_wrapper 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be a Wrapper class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          member_wrapper String
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end

    it 'inherits from superclass' do
      parent = Class.new(described_class) do
        member_wrapper Apiwork::Adapter::Wrapper::Member::Default
      end
      child = Class.new(parent)

      expect(child.member_wrapper).to eq(Apiwork::Adapter::Wrapper::Member::Default)
    end
  end

  describe '.resource_serializer' do
    it 'sets the resource serializer' do
      adapter_class = Class.new(described_class) do
        resource_serializer Apiwork::Adapter::Serializer::Resource::Default
      end

      expect(adapter_class.resource_serializer).to eq(Apiwork::Adapter::Serializer::Resource::Default)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          resource_serializer 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be a Serializer class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          resource_serializer String
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end

    it 'inherits from superclass' do
      parent = Class.new(described_class) do
        resource_serializer Apiwork::Adapter::Serializer::Resource::Default
      end
      child = Class.new(parent)

      expect(child.resource_serializer).to eq(Apiwork::Adapter::Serializer::Resource::Default)
    end
  end

  describe '.skip_capability' do
    it 'skips the capability' do
      capability_class = Class.new(Apiwork::Adapter::Capability::Base) do
        capability_name :unit_test_skip
      end
      adapter_class = Class.new(described_class) do
        capability capability_class
        skip_capability :unit_test_skip
      end

      expect(adapter_class.capabilities).not_to include(capability_class)
    end
  end
end
