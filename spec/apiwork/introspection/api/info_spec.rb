# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::API::Info do
  describe '#contact' do
    it 'returns the contact' do
      info = described_class.new(
        contact: { email: 'alice@example.com', name: 'Alice', url: nil },
        description: nil,
        license: nil,
        servers: [],
        summary: nil,
        terms_of_service: nil,
        title: nil,
        version: nil,
      )

      expect(info.contact).to be_a(Apiwork::Introspection::API::Info::Contact)
    end

    it 'returns nil when not set' do
      info = described_class.new(
        contact: nil,
        description: nil,
        license: nil,
        servers: [],
        summary: nil,
        terms_of_service: nil,
        title: nil,
        version: nil,
      )

      expect(info.contact).to be_nil
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      info = described_class.new(
        contact: nil,
        description: 'Ruby developer',
        license: nil,
        servers: [],
        summary: 'Rails tutorial',
        terms_of_service: 'https://example.com/alice.jpg',
        title: 'First Post',
        version: '1.0.0',
      )

      expect(info.title).to eq('First Post')
      expect(info.version).to eq('1.0.0')
      expect(info.description).to eq('Ruby developer')
      expect(info.summary).to eq('Rails tutorial')
      expect(info.terms_of_service).to eq('https://example.com/alice.jpg')
    end
  end

  describe '#license' do
    it 'returns the license' do
      info = described_class.new(
        contact: nil,
        description: nil,
        license: { name: 'MIT', url: nil },
        servers: [],
        summary: nil,
        terms_of_service: nil,
        title: nil,
        version: nil,
      )

      expect(info.license).to be_a(Apiwork::Introspection::API::Info::License)
    end

    it 'returns nil when not set' do
      info = described_class.new(
        contact: nil,
        description: nil,
        license: nil,
        servers: [],
        summary: nil,
        terms_of_service: nil,
        title: nil,
        version: nil,
      )

      expect(info.license).to be_nil
    end
  end

  describe '#servers' do
    it 'returns the servers' do
      info = described_class.new(
        contact: nil,
        description: nil,
        license: nil,
        servers: [{ description: 'Ruby developer', url: 'https://example.com/alice.jpg' }],
        summary: nil,
        terms_of_service: nil,
        title: nil,
        version: nil,
      )

      expect(info.servers.first).to be_a(Apiwork::Introspection::API::Info::Server)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      info = described_class.new(
        contact: nil,
        description: nil,
        license: nil,
        servers: [],
        summary: nil,
        terms_of_service: nil,
        title: 'First Post',
        version: '1.0.0',
      )

      expect(info.to_h).to eq(
        {
          contact: nil,
          description: nil,
          license: nil,
          servers: [],
          summary: nil,
          terms_of_service: nil,
          title: 'First Post',
          version: '1.0.0',
        },
      )
    end
  end
end
