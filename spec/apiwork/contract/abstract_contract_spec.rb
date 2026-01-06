# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Abstract Contract' do
  describe 'abstract behavior' do
    let(:abstract_contract) do
      create_test_contract do
        abstract!
      end
    end

    let(:concrete_contract) do
      Class.new(abstract_contract)
    end

    it 'allows marking class as abstract' do
      expect(abstract_contract.abstract?).to be true
    end

    it 'does not inherit abstract flag to subclasses' do
      expect(concrete_contract.abstract?).to be false
    end

    it 'subclass can explicitly be marked as abstract again' do
      another_abstract = Class.new(concrete_contract) do
        abstract!
      end

      expect(another_abstract.abstract?).to be true
    end
  end

  describe 'BaseContract pattern' do
    before(:all) do
      @test_api = Apiwork::API.define '/test_namespace' do
        resources :posts
      end

      module TestNamespace
        class PostSchema < Apiwork::Schema::Base
        end

        class BaseContract < Apiwork::Contract::Base
          abstract!
        end

        class PostContract < BaseContract
          schema!

          action :create do
            request do
              body do
                param :title, type: :string
              end
            end
          end
        end
      end
    end

    after(:all) do
      TestNamespace.send(:remove_const, :PostSchema)
      TestNamespace.send(:remove_const, :BaseContract)
      TestNamespace.send(:remove_const, :PostContract)
      Apiwork::API::Registry.unregister('/test_namespace')
    end

    it 'BaseContract is abstract' do
      expect(TestNamespace::BaseContract.abstract?).to be true
    end

    it 'PostContract inherits from BaseContract but is not abstract' do
      expect(TestNamespace::PostContract.superclass).to eq(TestNamespace::BaseContract)
      expect(TestNamespace::PostContract.abstract?).to be false
    end

    it 'PostContract can define actions normally' do
      action = TestNamespace::PostContract.action_for(:create)
      expect(action).not_to be_nil
      expect(action.name).to eq(:create)
    end
  end
end
