# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Resource::Resolver do
  before do
    # Clear the cache before each test
    described_class.clear_cache!
  end

  describe '.from_model' do
    context 'with a model instance' do
      let(:account) { Account.new }

      it 'resolves to AccountResource without namespace' do
        stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
        result = described_class.from_model(account)
        expect(result).to eq(AccountResource)
      end

      it 'resolves to namespaced resource when namespace provided' do
        stub_const('Api::V1::AccountResource', Class.new(Apiwork::Resource::Base))
        result = described_class.from_model(account, namespace: 'Api::V1')
        expect(result).to eq(Api::V1::AccountResource)
      end
    end

    context 'with a model class' do
      it 'resolves to resource class' do
        stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
        result = described_class.from_model(Account)
        expect(result).to eq(AccountResource)
      end
    end

    context 'when resource does not exist' do
      it 'raises ConfigurationError' do
        expect {
          described_class.from_model(Account)
        }.to raise_error(Apiwork::ConfigurationError, /Could not find Resource class/)
      end
    end

    context 'caching' do
      it 'caches the result' do
        stub_const('AccountResource', Class.new(Apiwork::Resource::Base))

        # First call
        result1 = described_class.from_model(Account)

        # Second call should use cache
        expect(Object).not_to receive(:const_get)
        result2 = described_class.from_model(Account)

        expect(result1).to eq(result2)
      end

      it 'uses different cache keys for different namespaces' do
        stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
        stub_const('Api::V1::AccountResource', Class.new(Apiwork::Resource::Base))

        result1 = described_class.from_model(Account)
        result2 = described_class.from_model(Account, namespace: 'Api::V1')

        expect(result1).to eq(AccountResource)
        expect(result2).to eq(Api::V1::AccountResource)
      end
    end
  end

  describe '.from_controller' do
    it 'extracts namespace from controller and resolves resource' do
      stub_const('Api::V1::AccountResource', Class.new(Apiwork::Resource::Base))
      stub_const('Api::V1::AccountsController', Class.new)

      result = described_class.from_controller(Api::V1::AccountsController)
      expect(result).to eq(Api::V1::AccountResource)
    end

    it 'handles controllers without namespace' do
      stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
      stub_const('AccountsController', Class.new)

      result = described_class.from_controller(AccountsController)
      expect(result).to eq(AccountResource)
    end

    it 'singularizes controller name' do
      stub_const('Api::V1::CommentResource', Class.new(Apiwork::Resource::Base))
      stub_const('Api::V1::CommentsController', Class.new)

      result = described_class.from_controller(Api::V1::CommentsController)
      expect(result).to eq(Api::V1::CommentResource)
    end

    it 'caches the result' do
      stub_const('Api::V1::AccountResource', Class.new(Apiwork::Resource::Base))
      stub_const('Api::V1::AccountsController', Class.new)

      result1 = described_class.from_controller(Api::V1::AccountsController)
      result2 = described_class.from_controller(Api::V1::AccountsController)

      expect(result1).to eq(result2)
    end
  end

  describe '.from_scope' do
    let(:scope) { Account.all }

    it 'resolves from ActiveRecord relation' do
      stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
      result = described_class.from_scope(scope)
      expect(result).to eq(AccountResource)
    end

    it 'resolves from single model instance' do
      account = Account.new
      stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
      result = described_class.from_scope(account)
      expect(result).to eq(AccountResource)
    end

    it 'uses namespace when provided' do
      stub_const('Api::V1::AccountResource', Class.new(Apiwork::Resource::Base))
      result = described_class.from_scope(scope, namespace: 'Api::V1')
      expect(result).to eq(Api::V1::AccountResource)
    end
  end

  describe '.from_association' do
    let(:reflection) do
      double('Reflection',
             klass: Account,
             name: :accounts,
             polymorphic?: false)
    end
    let(:parent_resource) do
      Class.new(Apiwork::Resource::Base) do
        def self.name
          'ParentResource'
        end
      end
    end

    it 'resolves resource from association reflection' do
      stub_const('AccountResource', Class.new(Apiwork::Resource::Base))
      result = described_class.from_association(reflection, parent_resource)
      expect(result).to eq(AccountResource)
    end

    it 'uses parent resource namespace' do
      stub_const('Api::V1::AccountResource', Class.new(Apiwork::Resource::Base))
      stub_const('Api::V1::ParentResource', Class.new(Apiwork::Resource::Base))

      result = described_class.from_association(reflection, Api::V1::ParentResource)
      expect(result).to eq(Api::V1::AccountResource)
    end
  end

  describe '.clear_cache!' do
    it 'clears the cache' do
      stub_const('AccountResource', Class.new(Apiwork::Resource::Base))

      # Populate cache
      described_class.from_model(Account)

      # Clear cache
      described_class.clear_cache!

      # Verify cache is empty by checking it resolves again
      expect(described_class.from_model(Account)).to eq(AccountResource)
    end
  end
end
