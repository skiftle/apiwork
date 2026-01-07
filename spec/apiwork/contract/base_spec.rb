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
    let(:base_contract) do
      Class.new(Apiwork::Contract::Base) do
        abstract!
      end
    end

    let(:post_contract) do
      Class.new(base_contract)
    end

    it 'BaseContract is abstract' do
      expect(base_contract.abstract?).to be true
    end

    it 'PostContract inherits from BaseContract but is not abstract' do
      expect(post_contract.superclass).to eq(base_contract)
      expect(post_contract.abstract?).to be false
    end

    it 'PostContract can be marked abstract again' do
      another_abstract = Class.new(post_contract) do
        abstract!
      end

      expect(another_abstract.abstract?).to be true
    end
  end
end
