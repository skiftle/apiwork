# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attribute preload' do
  describe 'preloads associations for custom attribute methods' do
    it 'includes preload associations in query' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :title, type: :string
        attribute :comment_count, preload: :comments, type: :integer

        define_method(:comment_count) do
          record.comments.size
        end
      end

      expect(representation_class.preloads).to eq([:comments])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Post.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data).to be_a(ActiveRecord::Relation)
      expect(preloaded_data.includes_values).to include(:comments)
    end

    it 'merges preloads with capability includes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :title, type: :string
        attribute :comment_count, preload: :comments, type: :integer

        define_method(:comment_count) do
          record.comments.size
        end
      end

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Post.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include(:comments)
    end

    it 'handles multiple preloads from different attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :comment_count, preload: :comments, type: :integer
        attribute :latest_comment, preload: :comments, type: :string

        define_method(:comment_count) do
          record.comments.size
        end

        define_method(:latest_comment) do
          record.comments.last&.content
        end
      end

      expect(representation_class.preloads).to eq([:comments, :comments])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Post.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include(:comments)
    end

    it 'handles nested preloads' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :comment_count, preload: { comments: :post }, type: :integer

        define_method(:comment_count) do
          record.comments.size
        end
      end

      expect(representation_class.preloads).to eq([{ comments: :post }])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Post.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include({ comments: :post })
    end

    it 'handles array preloads' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :meta, preload: [:comments, :author], type: :string

        define_method(:meta) do
          "#{record.comments.size} comments by #{record.author}"
        end
      end

      expect(representation_class.preloads).to eq([[:comments, :author]])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Post.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include(:comments, :author)
    end

    it 'returns empty array when no preloads defined' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :title, type: :string
      end

      expect(representation_class.preloads).to eq([])
    end
  end
end
