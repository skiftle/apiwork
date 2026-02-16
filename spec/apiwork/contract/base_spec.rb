# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Base do
  describe '.abstract!' do
    it 'marks the class as abstract' do
      contract_class = Class.new(described_class)
      contract_class.abstract!

      expect(contract_class.abstract?).to be(true)
    end
  end

  describe '.abstract?' do
    it 'returns true when abstract' do
      contract_class = Class.new(described_class)
      contract_class.abstract!

      expect(contract_class.abstract?).to be(true)
    end

    it 'returns false when not abstract' do
      contract_class = Class.new(described_class)

      expect(contract_class.abstract?).to be(false)
    end
  end

  describe '.action' do
    it 'registers the action' do
      contract_class = create_test_contract do
        action :create do
          request do
            body do
              string :title
            end
          end
        end
      end

      expect(contract_class.actions).to have_key(:create)
      expect(contract_class.actions[:create]).to be_a(Apiwork::Contract::Action)
    end
  end

  describe '.identifier' do
    it 'returns the identifier' do
      contract_class = create_test_contract do
        identifier :billing
      end

      expect(contract_class.identifier).to eq('billing')
    end

    it 'returns nil when not set' do
      contract_class = create_test_contract

      expect(contract_class.identifier).to be_nil
    end
  end

  describe '.import' do
    it 'registers the import' do
      imported_class = create_test_contract
      contract_class = create_test_contract do
        import imported_class, as: :billing
      end

      expect(contract_class.imports).to have_key(:billing)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        create_test_contract do
          import 'NotAClass', as: :billing
        end
      end.to raise_error(Apiwork::ConfigurationError, /import must be a Class constant/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        create_test_contract do
          import String, as: :billing
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end
  end

  describe '.enum' do
    it 'registers the enum' do
      contract_class = create_test_contract do
        enum :status, values: %w[draft sent paid]
      end

      expect(contract_class.enum?(:status)).to be(true)
    end
  end

  describe '.fragment' do
    it 'registers the fragment' do
      contract_class = create_test_contract do
        fragment :timestamps do
          datetime :created_at
        end
      end

      expect(contract_class.type?(:timestamps)).to be(true)
    end
  end

  describe '.object' do
    it 'registers the object' do
      contract_class = create_test_contract do
        object :item do
          string :title
        end
      end

      expect(contract_class.type?(:item)).to be(true)
    end
  end

  describe '.representation' do
    it 'sets the representation class' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      contract_class = create_test_contract do
        representation representation_class
      end

      expect(contract_class.representation_class).to eq(representation_class)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        create_test_contract do
          representation 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be a Representation class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        create_test_contract do
          representation String
        end
      end.to raise_error(Apiwork::ConfigurationError, /subclass of/)
    end
  end

  describe '.union' do
    it 'registers the union' do
      contract_class = create_test_contract do
        union :payment_method, discriminator: :type do
          variant tag: 'card' do
            object do
              string :last_four
            end
          end
        end
      end

      expect(contract_class.type?(:payment_method)).to be(true)
    end
  end
end
