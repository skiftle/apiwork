# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Polymorphic associations', type: :integration do
  # Stub representation classes for testing
  let(:post_representation_class) { Class.new(Apiwork::Representation::Base) { abstract! } }
  let(:video_representation_class) { Class.new(Apiwork::Representation::Base) { abstract! } }

  describe 'polymorphic association definition' do
    it 'accepts polymorphic option with types hash using class references' do
      post_representation = post_representation_class
      video_representation = video_representation_class

      representation = Class.new(Apiwork::Representation::Base) do
        abstract!

        belongs_to :commentable, polymorphic: { post: post_representation, video: video_representation }
      end

      association_def = representation.associations[:commentable]
      expect(association_def.polymorphic?).to be true
      expect(association_def.polymorphic).to eq({ post: post_representation, video: video_representation })
    end

    it 'accepts polymorphic option with array shorthand' do
      stub_const('Api::V1::PostRepresentation', post_representation_class)
      stub_const('Api::V1::VideoRepresentation', video_representation_class)

      representation = Class.new(Apiwork::Representation::Base) do
        abstract!

        def self.name
          'Api::V1::CommentRepresentation'
        end

        belongs_to :commentable, polymorphic: %i[post video]
      end

      association_def = representation.associations[:commentable]
      expect(association_def.polymorphic?).to be true
      expect(association_def.polymorphic).to eq({ post: nil, video: nil })
      expect(association_def.resolve_polymorphic_representation(:post)).to eq(Api::V1::PostRepresentation)
      expect(association_def.resolve_polymorphic_representation(:video)).to eq(Api::V1::VideoRepresentation)
    end

    it 'rejects string values in polymorphic hash' do
      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          belongs_to :commentable, polymorphic: { post: 'PostSchema' }
        end
      end.to raise_error(Apiwork::ConfigurationError, /class references, not strings/)
    end

    it 'rejects string values for representation option' do
      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          has_many :comments, representation: 'CommentRepresentation'
        end
      end.to raise_error(Apiwork::ConfigurationError, /class reference, not a string/)
    end

    it 'auto-detects discriminator from reflection' do
      post_representation = post_representation_class
      video_representation = video_representation_class

      reflection = double(
        'ActiveRecord::Reflection',
        foreign_type: 'commentable_type',
        name: :commentable,
        polymorphic?: true,
      )

      model_class = Class.new(ApplicationRecord) do
        def self.name
          'TestModel'
        end

        def self.model_name
          ActiveModel::Name.new(self, nil, 'TestModel')
        end

        def self.columns_hash
          {}
        end
      end

      allow(model_class).to receive(:reflect_on_association).with(:commentable).and_return(reflection)

      representation = Class.new(Apiwork::Representation::Base) do
        model model_class

        belongs_to :commentable, polymorphic: { post: post_representation, video: video_representation }
      end

      association_def = representation.associations[:commentable]
      expect(association_def.discriminator).to eq(:commentable_type)
    end
  end

  describe 'polymorphic validation' do
    it 'rejects filterable with polymorphic' do
      post_representation = post_representation_class

      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          belongs_to :commentable, filterable: true, polymorphic: { post: post_representation }
        end
      end.to raise_error(Apiwork::ConfigurationError, /cannot use filterable: true/)
    end

    it 'rejects sortable with polymorphic' do
      post_representation = post_representation_class

      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          belongs_to :commentable, polymorphic: { post: post_representation }, sortable: true
        end
      end.to raise_error(Apiwork::ConfigurationError, /cannot use sortable: true/)
    end

    it 'allows include: :optional with polymorphic' do
      post_representation = post_representation_class

      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          belongs_to :commentable, include: :optional, polymorphic: { post: post_representation }
        end
      end.not_to raise_error
    end

    it 'allows include: :always with polymorphic' do
      post_representation = post_representation_class

      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          belongs_to :commentable, include: :always, polymorphic: { post: post_representation }
        end
      end.not_to raise_error
    end

    it 'rejects writable with polymorphic' do
      post_representation = post_representation_class

      expect do
        Class.new(Apiwork::Representation::Base) do
          abstract!

          belongs_to :commentable, polymorphic: { post: post_representation }, writable: true
        end
      end.to raise_error(Apiwork::ConfigurationError, /cannot use writable: true/)
    end
  end

  describe 'Polymorphic type discrimination with real data' do
    # Create test tags
    let!(:ruby_tag) { Tag.create!(name: 'Ruby', slug: 'ruby') }
    let!(:rails_tag) { Tag.create!(name: 'Rails', slug: 'rails') }
    let!(:testing_tag) { Tag.create!(name: 'Testing', slug: 'testing') }

    it 'correctly sets taggable_type for different models' do
      # Create post with tagging
      post = Post.create!(body: 'Body', published: true, title: 'Post')
      post_tagging = post.taggings.create!(tag: ruby_tag)

      # Create comment with tagging
      comment = Comment.create!(post:, author: 'Alice', content: 'Comment')
      comment_tagging = comment.taggings.create!(tag: rails_tag)

      # Create author with tagging
      author = Author.create!(name: 'Author')
      author_tagging = author.taggings.create!(tag: testing_tag)

      expect(post_tagging.reload.taggable_type).to eq('Post')
      expect(comment_tagging.reload.taggable_type).to eq('Comment')
      expect(author_tagging.reload.taggable_type).to eq('Author')
    end

    it 'maintains separate taggings for different taggable types' do
      post = Post.create!(body: 'Body', published: true, title: 'Post')
      comment = Comment.create!(post:, author: 'Alice', content: 'Comment')

      # Same tag on different taggable types
      post.taggings.create!(tag: ruby_tag)
      comment.taggings.create!(tag: ruby_tag)

      expect(Tagging.where(tag: ruby_tag, taggable_type: 'Post').count).to eq(1)
      expect(Tagging.where(tag: ruby_tag, taggable_type: 'Comment').count).to eq(1)
      expect(Tagging.where(tag: ruby_tag).count).to eq(2)
    end

    it 'allows same tag on different taggable types' do
      post = Post.create!(body: 'Body', published: true, title: 'Post')
      comment = Comment.create!(post:, author: 'Alice', content: 'Comment')
      author = Author.create!(name: 'Author')

      # Create same tag on all three types
      expect do
        post.taggings.create!(tag: ruby_tag)
        comment.taggings.create!(tag: ruby_tag)
        author.taggings.create!(tag: ruby_tag)
      end.to change(Tagging, :count).by(3)

      # Verify all taggings exist with correct types
      expect(ruby_tag.taggings.pluck(:taggable_type)).to contain_exactly('Post', 'Comment', 'Author')
    end
  end
end
