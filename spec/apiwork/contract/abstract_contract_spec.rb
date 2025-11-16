# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Abstract Contract' do
  describe 'abstract behavior' do
    let(:abstract_contract) do
      Class.new(Apiwork::Contract::Base) do
        abstract
      end
    end

    let(:concrete_contract) do
      Class.new(abstract_contract) do
        # Inherits from abstract contract
      end
    end

    it 'allows marking class as abstract' do
      expect(abstract_contract.abstract?).to be true
    end

    it 'does not inherit abstract flag to subclasses' do
      expect(concrete_contract.abstract?).to be false
    end

    it 'subclass can explicitly be marked as abstract again' do
      another_abstract = Class.new(concrete_contract) do
        abstract
      end

      expect(another_abstract.abstract?).to be true
    end
  end

  describe 'BaseContract pattern' do
    before(:all) do
      # Define abstract base contract for testing
      module TestNamespace
        class BaseContract < Apiwork::Contract::Base
          abstract
        end

        class ConcreteContract < BaseContract
          schema Api::V1::PostSchema

          action :create do
            input do
              param :title, type: :string
            end
          end
        end
      end
    end

    after(:all) do
      TestNamespace.send(:remove_const, :BaseContract)
      TestNamespace.send(:remove_const, :ConcreteContract)
    end

    it 'BaseContract is abstract' do
      expect(TestNamespace::BaseContract.abstract?).to be true
    end

    it 'ConcreteContract inherits from BaseContract but is not abstract' do
      expect(TestNamespace::ConcreteContract.superclass).to eq(TestNamespace::BaseContract)
      expect(TestNamespace::ConcreteContract.abstract?).to be false
    end

    it 'ConcreteContract can define actions normally' do
      action_definition = TestNamespace::ConcreteContract.action_definition(:create)
      expect(action_definition).not_to be_nil
      expect(action_definition.action_name).to eq(:create)
    end
  end
end
