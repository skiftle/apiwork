# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Deserializer do
  describe '#deserialize' do
    it 'returns the deserialized hash' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Post
        attribute :title
      end
      deserializer = described_class.new(representation_class)

      result = deserializer.deserialize({ title: 'First Post' })

      expect(result).to eq({ title: 'First Post' })
    end

    context 'with array payload' do
      it 'returns the deserialized array' do
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize([{ title: 'First Post' }, { title: 'Second Post' }])

        expect(result).to eq([{ title: 'First Post' }, { title: 'Second Post' }])
      end
    end

    context 'with collection association' do
      it 'returns the deserialized hash' do
        comment_representation = Class.new(Apiwork::Representation::Base) do
          model Comment
          attribute :body
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
          has_many :comments, representation: comment_representation
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize({ comments: [{ body: 'Rails tutorial' }], title: 'First Post' })

        expect(result).to eq({ comments: [{ body: 'Rails tutorial' }], title: 'First Post' })
      end
    end

    context 'with singular association' do
      it 'returns the deserialized hash' do
        post_representation = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Comment
          attribute :body
          belongs_to :post, representation: post_representation
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize({ body: 'Rails tutorial', post: { title: 'First Post' } })

        expect(result).to eq({ body: 'Rails tutorial', post: { title: 'First Post' } })
      end
    end

    context 'when key is not present in hash' do
      it 'returns an empty hash' do
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize({})

        expect(result).to eq({})
      end
    end
  end
end
