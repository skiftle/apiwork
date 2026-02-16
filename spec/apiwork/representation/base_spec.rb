# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Base do
  describe '.abstract!' do
    it 'marks the class as abstract' do
      representation_class = Class.new(described_class)
      representation_class.abstract!

      expect(representation_class.abstract?).to be(true)
    end
  end

  describe '.abstract?' do
    it 'returns true when abstract' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.abstract?).to be(true)
    end

    it 'returns false when not abstract' do
      representation_class = Class.new(described_class)

      expect(representation_class.abstract?).to be(false)
    end
  end

  describe '.attribute' do
    context 'with defaults' do
      it 'registers the attribute' do
        representation_class = Class.new(described_class) do
          model Post
          attribute :title
        end

        expect(representation_class.attributes[:title]).to be_a(Apiwork::Representation::Attribute)
        expect(representation_class.attributes[:title].name).to eq(:title)
        expect(representation_class.attributes[:title].type).to eq(:string)
        expect(representation_class.attributes[:title].deprecated?).to be(false)
        expect(representation_class.attributes[:title].filterable?).to be(false)
        expect(representation_class.attributes[:title].sortable?).to be(false)
        expect(representation_class.attributes[:title].writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        representation_class = Class.new(described_class) do
          model Post
          attribute :title,
                    deprecated: true,
                    description: 'The title',
                    enum: %w[draft published],
                    example: 'First Post',
                    filterable: true,
                    format: :email,
                    max: 100,
                    min: 1,
                    nullable: true,
                    optional: true,
                    preload: :comments,
                    sortable: true,
                    type: :string,
                    writable: true
        end

        attribute = representation_class.attributes[:title]
        expect(attribute.deprecated?).to be(true)
        expect(attribute.description).to eq('The title')
        expect(attribute.enum).to eq(%w[draft published])
        expect(attribute.example).to eq('First Post')
        expect(attribute.filterable?).to be(true)
        expect(attribute.format).to eq(:email)
        expect(attribute.max).to eq(100)
        expect(attribute.min).to eq(1)
        expect(attribute.nullable?).to be(true)
        expect(attribute.optional?).to be(true)
        expect(attribute.preload).to eq(:comments)
        expect(attribute.sortable?).to be(true)
        expect(attribute.type).to eq(:string)
        expect(attribute.writable?).to be(true)
      end
    end
  end

  describe '.belongs_to' do
    context 'with defaults' do
      it 'registers the association' do
        representation_class = Class.new(described_class) do
          abstract!
          belongs_to :author
        end

        association = representation_class.associations[:author]
        expect(association).to be_a(Apiwork::Representation::Association)
        expect(association.name).to eq(:author)
        expect(association.type).to eq(:belongs_to)
        expect(association.deprecated?).to be(false)
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(described_class) { abstract! }
        representation_class = Class.new(described_class) do
          abstract!
          belongs_to :author,
                     deprecated: true,
                     description: 'The author',
                     example: { id: 1 },
                     filterable: true,
                     include: :always,
                     nullable: true,
                     representation: target_representation,
                     sortable: true,
                     writable: true
        end

        association = representation_class.associations[:author]
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The author')
        expect(association.example).to eq({ id: 1 })
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '.deprecated!' do
    it 'marks the representation as deprecated' do
      representation_class = Class.new(described_class) do
        abstract!
        deprecated!
      end

      expect(representation_class.deprecated?).to be(true)
    end
  end

  describe '.deprecated?' do
    it 'returns true when deprecated' do
      representation_class = Class.new(described_class) do
        abstract!
        deprecated!
      end

      expect(representation_class.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.deprecated?).to be(false)
    end
  end

  describe '.description' do
    it 'returns the description' do
      representation_class = Class.new(described_class) do
        abstract!
        description 'A customer invoice'
      end

      expect(representation_class.description).to eq('A customer invoice')
    end

    it 'returns nil when not set' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.description).to be_nil
    end
  end

  describe '.example' do
    it 'returns the example' do
      representation_class = Class.new(described_class) do
        abstract!
        example id: 1, title: 'First Post'
      end

      expect(representation_class.example).to eq({ id: 1, title: 'First Post' })
    end

    it 'returns nil when not set' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.example).to be_nil
    end
  end

  describe '.has_many' do
    context 'with defaults' do
      it 'registers the association' do
        representation_class = Class.new(described_class) do
          abstract!
          has_many :comments
        end

        association = representation_class.associations[:comments]
        expect(association).to be_a(Apiwork::Representation::Association)
        expect(association.name).to eq(:comments)
        expect(association.type).to eq(:has_many)
        expect(association.deprecated?).to be(false)
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(described_class) { abstract! }
        representation_class = Class.new(described_class) do
          abstract!
          has_many :comments,
                   deprecated: true,
                   description: 'The comments',
                   example: [{ id: 1 }],
                   filterable: true,
                   include: :always,
                   representation: target_representation,
                   sortable: true,
                   writable: true
        end

        association = representation_class.associations[:comments]
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The comments')
        expect(association.example).to eq([{ id: 1 }])
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '.has_one' do
    context 'with defaults' do
      it 'registers the association' do
        representation_class = Class.new(described_class) do
          abstract!
          has_one :author
        end

        association = representation_class.associations[:author]
        expect(association).to be_a(Apiwork::Representation::Association)
        expect(association.name).to eq(:author)
        expect(association.type).to eq(:has_one)
        expect(association.deprecated?).to be(false)
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(described_class) { abstract! }
        representation_class = Class.new(described_class) do
          abstract!
          has_one :author,
                  deprecated: true,
                  description: 'The author',
                  example: { id: 1 },
                  filterable: true,
                  include: :always,
                  nullable: true,
                  representation: target_representation,
                  sortable: true,
                  writable: true
        end

        association = representation_class.associations[:author]
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The author')
        expect(association.example).to eq({ id: 1 })
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '.model' do
    it 'sets the model class' do
      representation_class = Class.new(described_class) do
        model Post
      end

      expect(representation_class.model_class).to eq(Post)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          model 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be an ActiveRecord model class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          model String
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be an ActiveRecord model class/)
    end
  end

  describe '.model_class' do
    it 'returns the model class' do
      representation_class = Class.new(described_class) do
        model Post
      end

      expect(representation_class.model_class).to eq(Post)
    end
  end

  describe '.polymorphic_name' do
    it 'returns the type name when set' do
      representation_class = Class.new(described_class) do
        model Post
        type_name :article
      end

      expect(representation_class.polymorphic_name).to eq('article')
    end

    it 'returns the model polymorphic name when not set' do
      representation_class = Class.new(described_class) do
        model Post
      end

      expect(representation_class.polymorphic_name).to eq('Post')
    end
  end

  describe '.root' do
    it 'sets the root key' do
      representation_class = Class.new(described_class) do
        model Post
        root :bill, :bills
      end

      root_key = representation_class.root_key
      expect(root_key.singular).to eq('bill')
      expect(root_key.plural).to eq('bills')
    end
  end

  describe '.root_key' do
    it 'returns the root key when set' do
      representation_class = Class.new(described_class) do
        model Post
        root :bill, :bills
      end

      root_key = representation_class.root_key
      expect(root_key.singular).to eq('bill')
      expect(root_key.plural).to eq('bills')
    end

    it 'returns the model root key when not set' do
      representation_class = Class.new(described_class) do
        model Post
      end

      root_key = representation_class.root_key
      expect(root_key.singular).to eq('post')
      expect(root_key.plural).to eq('posts')
    end
  end

  describe '.sti_name' do
    it 'returns the type name when set' do
      representation_class = Class.new(described_class) do
        model Post
        type_name :article
      end

      expect(representation_class.sti_name).to eq('article')
    end

    it 'returns the model STI name when not set' do
      representation_class = Class.new(described_class) do
        model Post
      end

      expect(representation_class.sti_name).to eq('Post')
    end
  end

  describe '.type_name' do
    it 'returns the type name' do
      representation_class = Class.new(described_class) do
        abstract!
        type_name :article
      end

      expect(representation_class.type_name).to eq('article')
    end

    it 'returns nil when not set' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.type_name).to be_nil
    end
  end
end
