# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generation::OpenAPI, skip: "OpenAPI generation tests temporarily disabled" do
  before do
    # Load test API
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
  end

  let(:generator) { described_class.new('/api/v1') }
  let(:spec) { generator.generate }

  describe '#generate' do
    it 'generates valid OpenAPI 3.1.0 structure' do
      expect(spec).to be_a(Hash)
      expect(spec[:openapi]).to eq('3.1.0')
      expect(spec).to have_key(:info)
      expect(spec).to have_key(:paths)
      expect(spec).to have_key(:components)
    end

    describe 'info object' do
      let(:info) { spec[:info] }

      it 'includes API metadata from doc' do
        expect(info[:title]).to eq('Test API')
        expect(info[:version]).to eq('1.0.0')
        expect(info[:description]).to eq('Test API for Apiwork gem')
      end

      it 'has required OpenAPI info fields' do
        expect(info).to have_key(:title)
        expect(info).to have_key(:version)
      end
    end

    describe 'paths object' do
      let(:paths) { spec[:paths] }

      it 'generates paths for all resources' do
        expect(paths).to be_a(Hash)
        expect(paths.size).to be > 0
      end

      describe 'CRUD action paths' do
        it 'generates index action (GET /posts)' do
          expect(paths).to have_key('/api/v1/posts')
          expect(paths['/api/v1/posts']).to have_key('get')
        end

        it 'generates show action (GET /posts/:id)' do
          expect(paths).to have_key('/api/v1/posts/:id')
          expect(paths['/api/v1/posts/:id']).to have_key('get')
        end

        it 'generates create action (POST /posts)' do
          expect(paths['/api/v1/posts']).to have_key('post')
        end

        it 'generates update action (PATCH /posts/:id)' do
          expect(paths['/api/v1/posts/:id']).to have_key('patch')
        end

        it 'generates destroy action (DELETE /posts/:id)' do
          expect(paths['/api/v1/posts/:id']).to have_key('delete')
        end
      end

      describe 'custom collection actions' do
        it 'generates search action path' do
          expect(paths).to have_key('/api/v1/posts/search')
          expect(paths['/api/v1/posts/search']).to have_key('get')
        end

        it 'generates bulk_create action path' do
          expect(paths).to have_key('/api/v1/posts/bulk_create')
          expect(paths['/api/v1/posts/bulk_create']).to have_key('post')
        end
      end

      describe 'custom member actions' do
        it 'generates publish action path' do
          expect(paths).to have_key('/api/v1/posts/:id/publish')
          expect(paths['/api/v1/posts/:id/publish']).to have_key('patch')
        end

        it 'generates archive action path' do
          expect(paths).to have_key('/api/v1/posts/:id/archive')
          expect(paths['/api/v1/posts/:id/archive']).to have_key('patch')
        end
      end

      describe 'operation objects' do
        let(:index_operation) { paths['/api/v1/posts']['get'] }

        it 'includes operationId' do
          expect(index_operation[:operationId]).to eq('index_posts')
        end

        it 'includes tags' do
          expect(index_operation[:tags]).to eq(['Posts'])
        end

        it 'includes responses' do
          expect(index_operation[:responses]).to be_a(Hash)
          expect(index_operation[:responses]).to have_key(:'200')
        end

        describe 'with input' do
          it 'includes requestBody' do
            expect(index_operation[:requestBody]).to be_a(Hash)
            expect(index_operation[:requestBody][:required]).to be true
            expect(index_operation[:requestBody][:content]).to have_key(:'application/json')
          end

          it 'references input component schema' do
            schema = index_operation[:requestBody][:content][:'application/json'][:schema]
            expect(schema[:'$ref']).to eq('#/components/schemas/IndexPostInput')
          end
        end

        describe 'with output' do
          let(:response) { index_operation[:responses][:'200'] }

          it 'includes successful response' do
            expect(response[:description]).to eq('Successful response')
            expect(response[:content]).to have_key(:'application/json')
          end

          it 'references output component schema' do
            schema = response[:content][:'application/json'][:schema]
            expect(schema[:'$ref']).to eq('#/components/schemas/PostList')
          end
        end

        describe 'without input' do
          let(:show_operation) { paths['/api/v1/posts/:id']['get'] }

          it 'does not include requestBody' do
            expect(show_operation[:requestBody]).to be_nil
          end
        end
      end
    end

    describe 'components object' do
      let(:components) { spec[:components] }
      let(:schemas) { components[:schemas] }

      it 'has schemas section' do
        expect(components).to have_key(:schemas)
        expect(schemas).to be_a(Hash)
      end

      describe 'input schemas' do
        it 'generates input schema for index action' do
          expect(schemas).to have_key(:IndexPostInput)
        end

        it 'generates input schema for create action' do
          expect(schemas).to have_key(:CreatePostInput)
        end

        it 'generates input schema for custom collection actions' do
          expect(schemas).to have_key(:SearchPostInput)
          expect(schemas).to have_key(:BulkCreatePostInput)
        end

        describe 'IndexPostInput schema' do
          let(:schema) { schemas[:IndexPostInput] }

          it 'is an object type' do
            expect(schema[:type]).to eq('object')
          end

          it 'has properties' do
            expect(schema[:properties]).to be_a(Hash)
            expect(schema[:properties]).to have_key(:filter)
            expect(schema[:properties]).to have_key(:sort)
            expect(schema[:properties]).to have_key(:page)
            expect(schema[:properties]).to have_key(:include)
          end

          describe 'filter property (union type)' do
            let(:filter) { schema[:properties][:filter] }

            it 'uses oneOf for union' do
              expect(filter).to have_key(:oneOf)
              expect(filter[:oneOf]).to be_an(Array)
              expect(filter[:oneOf].size).to be > 1
            end

            it 'includes object variant' do
              object_variant = filter[:oneOf].find { |v| v[:type] == 'object' }
              expect(object_variant).not_to be_nil
              expect(object_variant[:properties]).to be_a(Hash)
            end

            it 'includes array variant' do
              array_variant = filter[:oneOf].find { |v| v[:type] == 'array' }
              expect(array_variant).not_to be_nil
              expect(array_variant[:items]).to be_a(Hash)
            end
          end

          describe 'page property (nested object)' do
            let(:page) { schema[:properties][:page] }

            it 'is an object with properties' do
              expect(page[:type]).to eq('object')
              expect(page[:properties]).to have_key(:number)
              expect(page[:properties]).to have_key(:size)
            end

            it 'has correct property types' do
              expect(page[:properties][:number][:type]).to eq('integer')
              expect(page[:properties][:size][:type]).to eq('integer')
            end
          end
        end

        describe 'CreatePostInput schema' do
          let(:schema) { schemas[:CreatePostInput] }

          it 'has post property (nested object)' do
            expect(schema[:properties]).to have_key(:post)
            post = schema[:properties][:post]
            expect(post[:type]).to eq('object')
          end
        end
      end

      describe 'output schemas' do
        it 'generates output schema for single resources' do
          expect(schemas).to have_key(:Post)
          expect(schemas).to have_key(:Article)
        end

        it 'generates output schema for collections' do
          expect(schemas).to have_key(:PostList)
          expect(schemas).to have_key(:ArticleList)
        end

        describe 'Post schema' do
          let(:schema) { schemas[:Post] }

          it 'is an object type' do
            expect(schema[:type]).to eq('object')
          end

          it 'has resource properties' do
            expect(schema[:properties]).to be_a(Hash)
            expect(schema[:properties]).to have_key(:id)
            expect(schema[:properties]).to have_key(:title)
            expect(schema[:properties]).to have_key(:body)
          end

          it 'has correct property types' do
            expect(schema[:properties][:id][:type]).to eq('integer')
            expect(schema[:properties][:title][:type]).to eq('string')
            expect(schema[:properties][:published][:type]).to eq('boolean')
          end
        end

        describe 'PostList schema' do
          let(:schema) { schemas[:PostList] }

          it 'has collection structure' do
            expect(schema[:type]).to eq('object')
            expect(schema[:properties]).to have_key(:posts)
          end
        end
      end

      describe 'type mappings' do
        let(:post_schema) { schemas[:Post] }

        it 'maps integer type correctly' do
          expect(post_schema[:properties][:id][:type]).to eq('integer')
        end

        it 'maps string type correctly' do
          expect(post_schema[:properties][:title][:type]).to eq('string')
        end

        it 'maps boolean type correctly' do
          expect(post_schema[:properties][:published][:type]).to eq('boolean')
        end

        it 'maps datetime type to string' do
          expect(post_schema[:properties][:created_at][:type]).to eq('string')
          expect(post_schema[:properties][:updated_at][:type]).to eq('string')
        end
      end

      describe 'array types' do
        let(:bulk_create_schema) { schemas[:BulkCreatePostInput] }

        it 'maps array types with items' do
          posts_array = bulk_create_schema[:properties][:posts]
          expect(posts_array[:type]).to eq('array')
          expect(posts_array[:items]).to be_a(Hash)
        end
      end

      describe 'union types' do
        let(:index_schema) { schemas[:IndexPostInput] }
        let(:filter) { index_schema[:properties][:filter] }

        it 'maps union types to oneOf' do
          expect(filter).to have_key(:oneOf)
        end

        it 'includes all variants' do
          expect(filter[:oneOf]).to be_an(Array)
          expect(filter[:oneOf].size).to be >= 2
        end

        it 'each variant has valid schema' do
          filter[:oneOf].each do |variant|
            expect(variant).to have_key(:type)
          end
        end
      end

      describe 'nested unions' do
        let(:index_schema) { schemas[:IndexPostInput] }
        let(:filter_object) { index_schema[:properties][:filter][:oneOf].find { |v| v[:type] == 'object' } }

        it 'handles nested union in object properties' do
          # The id property should be a union (integer | filter object)
          id_prop = filter_object[:properties][:id]
          expect(id_prop).to have_key(:oneOf)
        end

        it 'nested union variants are valid' do
          id_prop = filter_object[:properties][:id]
          expect(id_prop[:oneOf].size).to be >= 2

          # Should have integer variant
          int_variant = id_prop[:oneOf].find { |v| v[:type] == 'integer' }
          expect(int_variant).not_to be_nil

          # Should have object variant (numeric_filter)
          obj_variant = id_prop[:oneOf].find { |v| v[:type] == 'object' }
          expect(obj_variant).not_to be_nil
        end
      end

      describe 'deeply nested objects' do
        let(:index_schema) { schemas[:IndexPostInput] }
        let(:filter_object) { index_schema[:properties][:filter][:oneOf].find { |v| v[:type] == 'object' } }
        let(:numeric_filter) { filter_object[:properties][:id][:oneOf].find { |v| v[:type] == 'object' } }

        it 'handles between property (object with from/to)' do
          between = numeric_filter[:properties][:between]
          expect(between[:type]).to eq('object')
          expect(between[:properties]).to have_key(:from)
          expect(between[:properties]).to have_key(:to)
          expect(between[:properties][:from][:type]).to eq('integer')
          expect(between[:properties][:to][:type]).to eq('integer')
        end
      end
    end

    describe 'component reuse and deduplication' do
      it 'reuses same output schema for show/create/update actions' do
        show_ref = spec[:paths]['/api/v1/posts/:id']['get'][:responses][:'200'][:content][:'application/json'][:schema][:'$ref']
        create_ref = spec[:paths]['/api/v1/posts']['post'][:responses][:'200'][:content][:'application/json'][:schema][:'$ref']

        # Both should reference the same Post schema
        expect(show_ref).to eq('#/components/schemas/Post')
        expect(create_ref).to eq('#/components/schemas/Post')
      end

      it 'uses different input schemas for different actions' do
        index_ref = spec[:paths]['/api/v1/posts']['get'][:requestBody][:content][:'application/json'][:schema][:'$ref']
        create_ref = spec[:paths]['/api/v1/posts']['post'][:requestBody][:content][:'application/json'][:schema][:'$ref']

        expect(index_ref).to eq('#/components/schemas/IndexPostInput')
        expect(create_ref).to eq('#/components/schemas/CreatePostInput')
      end
    end

    describe 'different resource types' do
      describe 'articles resource' do
        it 'generates paths for articles' do
          expect(spec[:paths]).to have_key('/api/v1/articles')
          expect(spec[:paths]['/api/v1/articles']).to have_key('get')
        end

        it 'generates article schemas' do
          expect(spec[:components][:schemas]).to have_key(:Article)
          expect(spec[:components][:schemas]).to have_key(:ArticleList)
          expect(spec[:components][:schemas]).to have_key(:CreateArticleInput)
        end
      end

      describe 'restricted resources (only specific actions)' do
        it 'only includes allowed actions for restricted_posts' do
          # restricted_posts only has index and show
          expect(spec[:paths]).to have_key('/api/v1/restricted_posts')
          expect(spec[:paths]['/api/v1/restricted_posts']).to have_key('get') # index

          expect(spec[:paths]).to have_key('/api/v1/restricted_posts/:id')
          expect(spec[:paths]['/api/v1/restricted_posts/:id']).to have_key('get') # show

          # Should NOT have create/update/destroy
          expect(spec[:paths]['/api/v1/restricted_posts']).not_to have_key('post')
          expect(spec[:paths]['/api/v1/restricted_posts/:id']).not_to have_key('patch')
          expect(spec[:paths]['/api/v1/restricted_posts/:id']).not_to have_key('delete')
        end
      end

      describe 'safe resources (except destroy)' do
        it 'includes all actions except destroy for safe_comments' do
          # safe_comments has index, show, create, update
          expect(spec[:paths]).to have_key('/api/v1/safe_comments')
          expect(spec[:paths]['/api/v1/safe_comments']).to have_key('get') # index
          expect(spec[:paths]['/api/v1/safe_comments']).to have_key('post') # create

          expect(spec[:paths]).to have_key('/api/v1/safe_comments/:id')
          expect(spec[:paths]['/api/v1/safe_comments/:id']).to have_key('get') # show
          expect(spec[:paths]['/api/v1/safe_comments/:id']).to have_key('patch') # update

          # Should NOT have destroy
          expect(spec[:paths]['/api/v1/safe_comments/:id']).not_to have_key('delete')
        end
      end
    end

    describe 'edge cases' do
      describe 'resources without contracts' do
        it 'handles resources that have no explicit contract class' do
          # comments, persons have no explicit contracts - should not generate paths
          comment_paths = spec[:paths].select { |k, _v| k.include?('comment') && !k.include?('safe_comment') }
          person_paths = spec[:paths].select { |k, _v| k.include?('person') }

          expect(comment_paths).to be_empty
          expect(person_paths).to be_empty
        end
      end

      describe 'actions without output' do
        let(:destroy_operation) { spec[:paths]['/api/v1/posts/:id']['delete'] }

        it 'returns 204 No Content for actions without output' do
          expect(destroy_operation[:responses]).to have_key(:'204')
          expect(destroy_operation[:responses][:'204'][:description]).to eq('No content')
        end
      end
    end

    describe 'JSON serialization' do
      it 'can be serialized to JSON without errors' do
        expect { JSON.generate(spec) }.not_to raise_error
      end

      it 'produces valid JSON structure' do
        json_string = JSON.generate(spec)
        parsed = JSON.parse(json_string)

        expect(parsed['openapi']).to eq('3.1.0')
        expect(parsed['info']).to be_a(Hash)
        expect(parsed['paths']).to be_a(Hash)
        expect(parsed['components']['schemas']).to be_a(Hash)
      end
    end
  end

  describe '.file_extension' do
    it 'returns .json' do
      expect(described_class.file_extension).to eq('.json')
    end
  end

  describe '.generator_name' do
    it 'returns :openapi' do
      expect(described_class.generator_name).to eq(:openapi)
    end
  end

  describe '.content_type' do
    it 'returns application/json' do
      expect(described_class.content_type).to eq('application/json')
    end
  end
end
