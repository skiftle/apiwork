# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Info do
  describe '#contact' do
    it 'defines a contact' do
      info = described_class.new
      info.contact do
        name 'Alice'
        email 'alice@example.com'
      end

      expect(info.contact).to be_a(Apiwork::API::Info::Contact)
      expect(info.contact.name).to eq('Alice')
    end
  end

  describe '#deprecated!' do
    it 'marks the API as deprecated' do
      info = described_class.new
      info.deprecated!

      expect(info.deprecated?).to be(true)
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      info = described_class.new
      info.deprecated!

      expect(info.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      info = described_class.new

      expect(info.deprecated?).to be(false)
    end
  end

  describe '#description' do
    it 'returns the description' do
      info = described_class.new
      info.description 'Invoice management API'

      expect(info.description).to eq('Invoice management API')
    end

    it 'returns nil when not set' do
      info = described_class.new

      expect(info.description).to be_nil
    end
  end

  describe '#license' do
    it 'defines a license' do
      info = described_class.new
      info.license do
        name 'MIT'
        url 'https://opensource.org/licenses/MIT'
      end

      expect(info.license).to be_a(Apiwork::API::Info::License)
      expect(info.license.name).to eq('MIT')
    end
  end

  describe '#server' do
    it 'defines a server' do
      info = described_class.new
      info.server do
        url 'https://example.com'
        description 'Production'
      end

      servers = info.server
      expect(servers.length).to eq(1)
      expect(servers.first.url).to eq('https://example.com')
    end
  end

  describe '#summary' do
    it 'returns the summary' do
      info = described_class.new
      info.summary 'Invoice management API'

      expect(info.summary).to eq('Invoice management API')
    end

    it 'returns nil when not set' do
      info = described_class.new

      expect(info.summary).to be_nil
    end
  end

  describe '#tags' do
    it 'returns the tags' do
      info = described_class.new
      info.tags 'invoices', 'payments'

      expect(info.tags).to eq(%w[invoices payments])
    end

    it 'returns empty array when not set' do
      info = described_class.new

      expect(info.tags).to eq([])
    end
  end

  describe '#terms_of_service' do
    it 'returns the terms of service' do
      info = described_class.new
      info.terms_of_service 'https://example.com/terms'

      expect(info.terms_of_service).to eq('https://example.com/terms')
    end

    it 'returns nil when not set' do
      info = described_class.new

      expect(info.terms_of_service).to be_nil
    end
  end

  describe '#title' do
    it 'returns the title' do
      info = described_class.new
      info.title 'Invoice API'

      expect(info.title).to eq('Invoice API')
    end

    it 'returns nil when not set' do
      info = described_class.new

      expect(info.title).to be_nil
    end
  end

  describe '#version' do
    it 'returns the version' do
      info = described_class.new
      info.version '1.0.0'

      expect(info.version).to eq('1.0.0')
    end

    it 'returns nil when not set' do
      info = described_class.new

      expect(info.version).to be_nil
    end
  end
end
