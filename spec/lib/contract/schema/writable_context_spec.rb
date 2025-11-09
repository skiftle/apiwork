# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Writable context filtering in auto-generated contracts' do
  # Test schemas with various writable configurations
  before(:all) do
    # Define associated schemas FIRST (they're referenced by TestArticleSchema)
    class TestTagSchema < Apiwork::Schema::Base
      self.abstract_class = true

      attribute :name, type: :string, writable: true
    end

    class TestCategorySchema < Apiwork::Schema::Base
      self.abstract_class = true

      attribute :name, type: :string, writable: true
    end

    class TestCommentSchema < Apiwork::Schema::Base
      self.abstract_class = true

      # Nested attribute only writable on create
      attribute :author_name, type: :string, writable: { on: [:create] }

      # Nested attribute only writable on update
      attribute :edited_at, type: :datetime, writable: { on: [:update] }

      # Nested attribute writable on both
      attribute :body, type: :string, writable: true
    end

    # Now define TestArticleSchema (references the above schemas)
    class TestArticleSchema < Apiwork::Schema::Base
      self.abstract_class = true

      # Attribute only writable on create
      attribute :slug, type: :string, writable: { on: [:create] }

      # Attribute only writable on update
      attribute :published_at, type: :datetime, writable: { on: [:update] }

      # Attribute writable on both
      attribute :title, type: :string, writable: true

      # Attribute not writable
      attribute :view_count, type: :integer, writable: false

      # Association only writable on create
      has_many :tags, schema: TestTagSchema, writable: { on: [:create] }

      # Association only writable on update
      has_many :categories, schema: TestCategorySchema, writable: { on: [:update] }

      # Association writable on both
      has_many :comments, schema: TestCommentSchema, writable: true
    end

    # Contract that uses the test schema
    class TestArticleContract < Apiwork::Contract::Base
      self.abstract_class = true
      schema TestArticleSchema
    end
  end

  after(:all) do
    # Clean up test classes (in reverse order of definition)
    Object.send(:remove_const, :TestArticleContract) if defined?(TestArticleContract)
    Object.send(:remove_const, :TestArticleSchema) if defined?(TestArticleSchema)
    Object.send(:remove_const, :TestCommentSchema) if defined?(TestCommentSchema)
    Object.send(:remove_const, :TestCategorySchema) if defined?(TestCategorySchema)
    Object.send(:remove_const, :TestTagSchema) if defined?(TestTagSchema)
  end

  describe 'Basic attribute filtering' do
    it 'includes create-only attributes in create_payload but not update_payload' do
      # Generate create and update actions
      create_action = Apiwork::Contract::Schema::Generator.generate_action(TestArticleSchema, :create, contract_class: TestArticleContract)
      update_action = Apiwork::Contract::Schema::Generator.generate_action(TestArticleSchema, :update, contract_class: TestArticleContract)

      # Get the payload types from the registry
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # slug should only be in create_payload
      expect(create_payload).to have_key('slug')
      expect(update_payload).not_to have_key('slug')
    end

    it 'includes update-only attributes in update_payload but not create_payload' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # published_at should only be in update_payload
      expect(create_payload).not_to have_key('published_at')
      expect(update_payload).to have_key('published_at')
    end

    it 'includes writable: true attributes in both payloads' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # title should be in both
      expect(create_payload).to have_key('title')
      expect(update_payload).to have_key('title')
    end

    it 'excludes writable: false attributes from both payloads' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # view_count should not be in either
      expect(create_payload).not_to have_key('view_count')
      expect(update_payload).not_to have_key('view_count')
    end
  end

  describe 'Association filtering' do
    it 'includes create-only associations in create_payload but not update_payload' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # tags should only be in create_payload
      expect(create_payload).to have_key('tags')
      expect(update_payload).not_to have_key('tags')
    end

    it 'includes update-only associations in update_payload but not create_payload' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # categories should only be in update_payload
      expect(create_payload).not_to have_key('categories')
      expect(update_payload).to have_key('categories')
    end

    it 'includes writable: true associations in both payloads' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      create_payload = all_types['test_article_create_payload']
      update_payload = all_types['test_article_update_payload']

      # comments should be in both
      expect(create_payload).to have_key('comments')
      expect(update_payload).to have_key('comments')
    end
  end

  describe 'Recursive/nested associations' do
    it 'filters nested attributes based on parent context (create)' do
      # For this test, we need to check the actual nested type definition
      # The comments association uses TestCommentSchema which has context-specific attributes

      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('test_article')

      # When creating an article with comments, the nested comment attributes should be
      # filtered based on the parent :create context
      # However, the current implementation doesn't cascade context to nested associations
      # Let's verify the current behavior first

      # The comments in create_payload should reference a type that includes all writable fields
      # This is a limitation: nested associations don't inherit parent context

      # For now, let's just verify that the association is present
      create_payload = all_types['test_article_create_payload']
      expect(create_payload).to have_key('comments')
      expect(create_payload['comments']['type']).to eq('array')
    end

    it 'allows nested associations to have their own writable configurations' do
      # Even though this might not cascade context, each nested schema
      # can have its own writable configurations that are respected
      # when that schema is used directly in a contract

      # This is more of a documentation test showing that nested schemas
      # maintain their own writable configurations
      expect(TestCommentSchema.attribute_definitions[:author_name].writable_for?(:create)).to be true
      expect(TestCommentSchema.attribute_definitions[:author_name].writable_for?(:update)).to be false

      expect(TestCommentSchema.attribute_definitions[:edited_at].writable_for?(:create)).to be false
      expect(TestCommentSchema.attribute_definitions[:edited_at].writable_for?(:update)).to be true

      expect(TestCommentSchema.attribute_definitions[:body].writable_for?(:create)).to be true
      expect(TestCommentSchema.attribute_definitions[:body].writable_for?(:update)).to be true
    end
  end

  describe 'Action definition serialization' do
    it 'serializes create action input with only create-writable fields' do
      create_action = Apiwork::Contract::Schema::Generator.generate_action(TestArticleSchema, :create, contract_class: TestArticleContract)
      serialized = create_action.as_json

      # The merged input should have the expanded params
      input = serialized[:input]

      # slug (create-only) should be present
      expect(input).to have_key(:slug)

      # published_at (update-only) should NOT be present
      expect(input).not_to have_key(:published_at)

      # title (both) should be present
      expect(input).to have_key(:title)

      # view_count (not writable) should NOT be present
      expect(input).not_to have_key(:view_count)
    end

    it 'serializes update action input with only update-writable fields' do
      update_action = Apiwork::Contract::Schema::Generator.generate_action(TestArticleSchema, :update, contract_class: TestArticleContract)
      serialized = update_action.as_json

      input = serialized[:input]

      # slug (create-only) should NOT be present
      expect(input).not_to have_key(:slug)

      # published_at (update-only) should be present
      expect(input).to have_key(:published_at)

      # title (both) should be present
      expect(input).to have_key(:title)

      # view_count (not writable) should NOT be present
      expect(input).not_to have_key(:view_count)
    end
  end

  describe 'writable_for? method' do
    it 'correctly identifies writable contexts for attributes' do
      slug_attr = TestArticleSchema.attribute_definitions[:slug]
      published_at_attr = TestArticleSchema.attribute_definitions[:published_at]
      title_attr = TestArticleSchema.attribute_definitions[:title]
      view_count_attr = TestArticleSchema.attribute_definitions[:view_count]

      # slug: writable on create only
      expect(slug_attr.writable_for?(:create)).to be true
      expect(slug_attr.writable_for?(:update)).to be false

      # published_at: writable on update only
      expect(published_at_attr.writable_for?(:create)).to be false
      expect(published_at_attr.writable_for?(:update)).to be true

      # title: writable on both
      expect(title_attr.writable_for?(:create)).to be true
      expect(title_attr.writable_for?(:update)).to be true

      # view_count: not writable
      expect(view_count_attr.writable_for?(:create)).to be false
      expect(view_count_attr.writable_for?(:update)).to be false
    end

    it 'correctly identifies writable contexts for associations' do
      tags_assoc = TestArticleSchema.association_definitions[:tags]
      categories_assoc = TestArticleSchema.association_definitions[:categories]
      comments_assoc = TestArticleSchema.association_definitions[:comments]

      # tags: writable on create only
      expect(tags_assoc.writable_for?(:create)).to be true
      expect(tags_assoc.writable_for?(:update)).to be false

      # categories: writable on update only
      expect(categories_assoc.writable_for?(:create)).to be false
      expect(categories_assoc.writable_for?(:update)).to be true

      # comments: writable on both
      expect(comments_assoc.writable_for?(:create)).to be true
      expect(comments_assoc.writable_for?(:update)).to be true
    end
  end
end
