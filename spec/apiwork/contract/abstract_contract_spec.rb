# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Abstract Contract' do
  describe 'abstract_class behavior' do
    let(:abstract_contract) do
      Class.new(Apiwork::Contract::Base) do
        self.abstract_class = true
      end
    end

    let(:concrete_contract) do
      Class.new(abstract_contract) do
        # Inherits from abstract contract
      end
    end

    it 'allows setting abstract_class to true' do
      expect(abstract_contract.abstract_class).to be true
    end

    it 'provides abstract_class? helper' do
      expect(abstract_contract.abstract_class?).to be true
    end

    it 'does not inherit abstract_class flag to subclasses' do
      expect(concrete_contract.abstract_class).to be false
    end

    it 'subclass can explicitly set abstract_class again' do
      another_abstract = Class.new(concrete_contract) do
        self.abstract_class = true
      end

      expect(another_abstract.abstract_class).to be true
      expect(another_abstract.abstract_class?).to be true
    end

    it 'uses underscore-prefixed internal attribute' do
      # Verify internal implementation uses _abstract_class
      expect(abstract_contract).to respond_to(:_abstract_class)
      expect(abstract_contract._abstract_class).to be true
    end
  end

  describe 'BaseContract pattern' do
    before(:all) do
      # Define abstract base contract for testing
      module TestNamespace
        class BaseContract < Apiwork::Contract::Base
          self.abstract_class = true
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
      expect(TestNamespace::BaseContract.abstract_class).to be true
    end

    it 'ConcreteContract inherits from BaseContract but is not abstract' do
      expect(TestNamespace::ConcreteContract.superclass).to eq(TestNamespace::BaseContract)
      expect(TestNamespace::ConcreteContract.abstract_class).to be false
    end

    it 'ConcreteContract can define actions normally' do
      action_def = TestNamespace::ConcreteContract.action_definition(:create)
      expect(action_def).not_to be_nil
      expect(action_def.action_name).to eq(:create)
    end
  end
end
