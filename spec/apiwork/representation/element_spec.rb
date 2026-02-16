# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Element do
  describe '#of' do
    context 'when type is :object' do
      it 'defines an object element' do
        element = described_class.new
        element.of(:object) do
          string :title
        end

        expect(element.type).to eq(:object)
        expect(element.shape).to be_a(Apiwork::API::Object)
      end
    end

    context 'when type is :array' do
      it 'defines an array element' do
        element = described_class.new
        element.of(:array) do
          string
        end

        expect(element.type).to eq(:array)
      end
    end

    context 'when type is :union' do
      it 'defines a union element' do
        element = described_class.new
        element.of(:union, discriminator: :type) do
          variant tag: 'card' do
            object do
              string :last_four
            end
          end
        end

        expect(element.type).to eq(:union)
      end
    end

    context 'when type is unsupported' do
      it 'raises ConfigurationError' do
        element = described_class.new

        expect do
          element.of(:string)
        end.to raise_error(Apiwork::ConfigurationError, /only supports/)
      end
    end
  end
end
