# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Wrapper::Base do
  describe '.shape' do
    it 'returns the shape' do
      shape_class = Class.new(Apiwork::Adapter::Wrapper::Shape)
      wrapper_class = Class.new(described_class) do
        shape shape_class
      end

      expect(wrapper_class.shape).to eq(shape_class)
    end

    it 'returns nil when not set' do
      wrapper_class = Class.new(described_class)

      expect(wrapper_class.shape).to be_nil
    end

    context 'when set with a block' do
      it 'returns the shape' do
        wrapper_class = Class.new(described_class) do
          shape do
            string :label
          end
        end

        expect(wrapper_class.shape).to be < Apiwork::Adapter::Wrapper::Shape
      end
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      data = { id: 1, title: 'First Post' }

      wrapper = described_class.new(data)

      expect(wrapper.data).to eq(data)
    end
  end

  describe '#wrap' do
    it 'raises NotImplementedError' do
      wrapper = described_class.new({})

      expect { wrapper.wrap }.to raise_error(NotImplementedError)
    end
  end
end
