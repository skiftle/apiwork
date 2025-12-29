# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Actions API', type: :request do
  describe 'Custom member actions' do
    describe 'PATCH /api/v1/posts/:id/publish' do
      it 'routes to custom member action and serializes response' do
        post = Post.create!(body: 'Draft content', published: false, title: 'Draft Post')
        expect(post.published).to be(false)

        patch "/api/v1/posts/#{post.id}/publish"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['id']).to eq(post.id)
        expect(json['post']['published']).to be(true)

        post.reload
        expect(post.published).to be(true)
      end

      it 'works with idempotent operations' do
        post = Post.create!(body: 'Content', published: true, title: 'Published Post')

        patch "/api/v1/posts/#{post.id}/publish"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['published']).to be(true)
      end

      it 'returns 404 for custom member actions' do
        patch '/api/v1/posts/99999/publish'

        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PATCH /api/v1/posts/:id/archive' do
      it 'handles custom member actions that modify state' do
        post = Post.create!(body: 'Content', published: true, title: 'Published Post')
        expect(post.published).to be(true)

        patch "/api/v1/posts/#{post.id}/archive"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['id']).to eq(post.id)
        expect(json['post']['published']).to be(false)

        post.reload
        expect(post.published).to be(false)
      end

      it 'handles idempotent custom actions' do
        post = Post.create!(body: 'Content', published: false, title: 'Archived Post')

        patch "/api/v1/posts/#{post.id}/archive"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['published']).to be(false)
      end
    end

    describe 'GET /api/v1/posts/:id/preview' do
      it 'routes GET requests to custom member actions' do
        post = Post.create!(
          title: 'Test Post',
          body: 'This is a long post body.',
          published: true,
        )

        get "/api/v1/posts/#{post.id}/preview"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']).to be_present
        expect(json['post']['id']).to eq(post.id)
        expect(json['post']['title']).to eq('Test Post')
        expect(json['post']['body']).to eq('This is a long post body.')
        expect(json['post']['published']).to be(true)
      end

      it 'serializes resources with varying attribute values' do
        post = Post.create!(body: 'Short body', published: false, title: 'Short')

        get "/api/v1/posts/#{post.id}/preview"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['body']).to eq('Short body')
      end

      it 'handles nil values in serialization' do
        post = Post.create!(body: nil, published: false, title: 'No body')

        get "/api/v1/posts/#{post.id}/preview"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['body']).to be_nil
      end
    end
  end

  describe 'Custom collection actions' do
    describe 'GET /api/v1/posts/search' do
      before do
        Post.create!(body: 'Learn Ruby programming', published: true, title: 'Ruby Tutorial')
        Post.create!(body: 'Learn Rails framework', published: true, title: 'Rails Guide')
        Post.create!(body: 'Learn Python programming', published: false, title: 'Python Tutorial')
        Post.create!(body: 'Learn JavaScript', published: true, title: 'JavaScript Basics')
      end

      it 'routes to custom collection action with query params' do
        get '/api/v1/posts/search', params: { q: 'Ruby' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(1)
        expect(json['posts'][0]['title']).to eq('Ruby Tutorial')
      end

      it 'works with query params across attributes' do
        get '/api/v1/posts/search', params: { q: 'framework' }

        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(1)
        expect(json['posts'][0]['title']).to eq('Rails Guide')
      end

      it 'serializes filtered collections' do
        get '/api/v1/posts/search', params: { q: 'Tutorial' }

        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to include('Ruby Tutorial', 'Python Tutorial')
      end

      it 'uses default params when none provided' do
        get '/api/v1/posts/search'

        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(4)
      end

      it 'returns empty collections for custom actions' do
        get '/api/v1/posts/search', params: { q: 'NonExistent' }

        json = JSON.parse(response.body)
        expect(json['posts']).to eq([])
      end

      it 'processes query parameters' do
        get '/api/v1/posts/search', params: { q: 'ruby' }

        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(1)
      end
    end

    describe 'POST /api/v1/posts/bulk_create' do
      it 'parses array params and returns collection' do
        posts_params = {
          posts: [
            {
              body: 'Body 1',
              published: true,
              title: 'Post 1',
            },
            {
              body: 'Body 2',
              published: false,
              title: 'Post 2',
            },
            {
              body: 'Body 3',
              published: true,
              title: 'Post 3',
            },
          ],
        }

        expect do
          post '/api/v1/posts/bulk_create', as: :json, params: posts_params
        end.to change(Post, :count).by(3)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(3)

        titles = json['posts'].map { |p| p['title'] }.sort
        expect(titles).to eq(['Post 1', 'Post 2', 'Post 3'])
      end

      it 'handles empty arrays in custom actions' do
        post '/api/v1/posts/bulk_create', as: :json, params: { posts: [] }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['posts']).to eq([])
      end

      it 'applies defaults to array elements' do
        posts_params = {
          posts: [
            { body: 'Body', title: 'Post without published' },
          ],
        }

        post '/api/v1/posts/bulk_create', as: :json, params: posts_params

        json = JSON.parse(response.body)
        expect(json['posts'][0]['published']).to be(false)
      end

      it 'handles missing params gracefully' do
        post '/api/v1/posts/bulk_create', as: :json, params: {}

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['posts']).to eq([])
      end
    end
  end

  describe 'Interaction between standard and custom actions' do
    it 'works consistently with standard CRUD actions' do
      post = Post.create!(body: 'Body', published: false, title: 'Test')

      # Standard show
      get "/api/v1/posts/#{post.id}"
      expect(response).to have_http_status(:ok)

      # Custom publish
      patch "/api/v1/posts/#{post.id}/publish"
      expect(response).to have_http_status(:ok)

      # Standard show again to verify change
      get "/api/v1/posts/#{post.id}"
      json = JSON.parse(response.body)
      expect(json['post']['published']).to be(true)

      # Custom archive
      patch "/api/v1/posts/#{post.id}/archive"
      expect(response).to have_http_status(:ok)

      # Standard show to verify second change
      get "/api/v1/posts/#{post.id}"
      json = JSON.parse(response.body)
      expect(json['post']['published']).to be(false)
    end

    it 'custom and standard collection actions coexist' do
      Post.create!(body: 'Ruby content', published: true, title: 'Ruby Post')
      Post.create!(body: 'Python content', published: false, title: 'Python Post')

      # Standard index
      get '/api/v1/posts'
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(2)

      # Custom search
      get '/api/v1/posts/search', params: { q: 'Ruby' }
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(1)

      # Standard index still works
      get '/api/v1/posts'
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(2)
    end
  end

  describe 'Custom action input validation' do
    let!(:post_record) { Post.create!(body: 'Body', title: 'Test Post') }

    context 'archive action' do
      it 'validates boolean parameter types' do
        patch "/api/v1/posts/#{post_record.id}/archive",
              params: {
                notify_users: 'not-a-boolean',
              },
              as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        notify_issue = json['issues'].find { |issue| issue['pointer']&.include?('notify_users') }
        expect(notify_issue).to be_present
        expect(notify_issue['code']).to eq('type_invalid')
      end

      it 'rejects unknown fields' do
        patch "/api/v1/posts/#{post_record.id}/archive",
              params: {
                unknown_field: 'value',
              },
              as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        unknown_issue = json['issues'].find { |issue| issue['code'] == 'field_unknown' }
        expect(unknown_issue).to be_present
      end
    end
  end
end
