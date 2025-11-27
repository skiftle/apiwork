# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Polymorphic associations', type: :integration do
  describe 'polymorphic association definition' do
    it 'accepts polymorphic option with types hash' do
      schema = Class.new(Apiwork::Schema::Base) do
        abstract

        belongs_to :commentable, polymorphic: { post: 'Api::V1::PostSchema', video: 'Api::V1::VideoSchema' }
      end

      association_def = schema.association_definitions[:commentable]
      expect(association_def.polymorphic?).to be true
      expect(association_def.polymorphic).to eq({ post: 'Api::V1::PostSchema', video: 'Api::V1::VideoSchema' })
    end

    it 'auto-detects discriminator from reflection' do
      reflection = double(
        'ActiveRecord::Reflection',
        name: :commentable,
        foreign_type: 'commentable_type',
        polymorphic?: true
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

      schema = Class.new(Apiwork::Schema::Base) do
        model model_class

        belongs_to :commentable, polymorphic: { post: 'Api::V1::PostSchema', video: 'Api::V1::VideoSchema' }
      end

      association_def = schema.association_definitions[:commentable]
      expect(association_def.discriminator).to eq(:commentable_type)
    end
  end

  describe 'polymorphic validation' do
    it 'rejects filterable with polymorphic' do
      expect do
        Class.new(Apiwork::Schema::Base) do
          abstract

          belongs_to :commentable,
                     polymorphic: { post: 'Api::V1::PostSchema' },
                     filterable: true
        end
      end.to raise_error(Apiwork::ConfigurationError, /cannot use filterable: true/)
    end

    it 'rejects sortable with polymorphic' do
      expect do
        Class.new(Apiwork::Schema::Base) do
          abstract

          belongs_to :commentable,
                     polymorphic: { post: 'Api::V1::PostSchema' },
                     sortable: true
        end
      end.to raise_error(Apiwork::ConfigurationError, /cannot use sortable: true/)
    end

    it 'allows include: :optional with polymorphic' do
      expect do
        Class.new(Apiwork::Schema::Base) do
          abstract

          belongs_to :commentable,
                     polymorphic: { post: 'Api::V1::PostSchema' },
                     include: :optional
        end
      end.not_to raise_error
    end

    it 'allows include: :always with polymorphic' do
      expect do
        Class.new(Apiwork::Schema::Base) do
          abstract

          belongs_to :commentable,
                     polymorphic: { post: 'Api::V1::PostSchema' },
                     include: :always
        end
      end.not_to raise_error
    end

    it 'rejects writable with polymorphic' do
      expect do
        Class.new(Apiwork::Schema::Base) do
          abstract

          belongs_to :commentable,
                     polymorphic: { post: 'Api::V1::PostSchema' },
                     writable: true
        end
      end.to raise_error(Apiwork::ConfigurationError, /cannot use writable: true/)
    end
  end

  describe 'Polymorphic type discrimination with real data' do
    before(:all) do
      Apiwork::Descriptor::Registry.clear!
    end

    # Create test tags
    let!(:ruby_tag) { Tag.create!(name: 'Ruby', slug: 'ruby') }
    let!(:rails_tag) { Tag.create!(name: 'Rails', slug: 'rails') }
    let!(:testing_tag) { Tag.create!(name: 'Testing', slug: 'testing') }

    it 'correctly sets taggable_type for different models' do
      # Create post with tagging
      post = Post.create!(title: 'Post', body: 'Body', published: true)
      post_tagging = post.taggings.create!(tag: ruby_tag)

      # Create comment with tagging
      comment = Comment.create!(post: post, content: 'Comment', author: 'Alice')
      comment_tagging = comment.taggings.create!(tag: rails_tag)

      # Create author with tagging
      author = Author.create!(name: 'Author')
      author_tagging = author.taggings.create!(tag: testing_tag)

      expect(post_tagging.reload.taggable_type).to eq('Post')
      expect(comment_tagging.reload.taggable_type).to eq('Comment')
      expect(author_tagging.reload.taggable_type).to eq('Author')
    end

    it 'maintains separate taggings for different taggable types' do
      post = Post.create!(title: 'Post', body: 'Body', published: true)
      comment = Comment.create!(post: post, content: 'Comment', author: 'Alice')

      # Same tag on different taggable types
      post.taggings.create!(tag: ruby_tag)
      comment.taggings.create!(tag: ruby_tag)

      expect(Tagging.where(tag: ruby_tag, taggable_type: 'Post').count).to eq(1)
      expect(Tagging.where(tag: ruby_tag, taggable_type: 'Comment').count).to eq(1)
      expect(Tagging.where(tag: ruby_tag).count).to eq(2)
    end

    it 'allows same tag on different taggable types' do
      post = Post.create!(title: 'Post', body: 'Body', published: true)
      comment = Comment.create!(post: post, content: 'Comment', author: 'Alice')
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
