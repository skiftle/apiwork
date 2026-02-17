# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Serializer do
  describe '#serialize' do
    it 'returns the serialized hash' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Post
        attribute :title
      end
      post = Post.new(title: 'First Post')
      representation = representation_class.new(post)
      serializer = described_class.new(representation, nil)

      result = serializer.serialize

      expect(result).to eq({ title: 'First Post' })
    end

    context 'with always-included association' do
      it 'returns the serialized hash' do
        comment_representation = Class.new(Apiwork::Representation::Base) do
          model Comment
          attribute :body
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
          has_many :comments, include: :always, representation: comment_representation
        end
        post = Post.new(title: 'First Post')
        representation = representation_class.new(post)
        serializer = described_class.new(representation, nil)

        result = serializer.serialize

        expect(result).to eq({ comments: [], title: 'First Post' })
      end
    end

    context 'with optional association' do
      it 'returns the serialized hash' do
        comment_representation = Class.new(Apiwork::Representation::Base) do
          model Comment
          attribute :body
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
          has_many :comments, representation: comment_representation
        end
        post = Post.new(title: 'First Post')
        representation = representation_class.new(post)
        serializer = described_class.new(representation, nil)

        result = serializer.serialize

        expect(result).to eq({ title: 'First Post' })
      end
    end

    context 'with explicit includes' do
      it 'returns the serialized hash' do
        comment_representation = Class.new(Apiwork::Representation::Base) do
          model Comment
          attribute :body
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Post
          attribute :title
          has_many :comments, representation: comment_representation
        end
        post = Post.new(title: 'First Post')
        representation = representation_class.new(post)
        serializer = described_class.new(representation, [:comments])

        result = serializer.serialize

        expect(result).to eq({ comments: [], title: 'First Post' })
      end
    end
  end
end
