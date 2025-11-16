# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Actions API', type: :request do
  describe 'Custom member actions' do
    describe 'PATCH /api/v1/posts/:id/publish' do
      it 'routes to custom member action and serializes response' do
        post = Post.create!(title: 'Draft Post', body: 'Draft content', published: false)
        expect(post.published).to be(false)

        patch "/api/v1/posts/#{post.id}/publish"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['post']['id']).to eq(post.id)
        expect(json['post']['published']).to be(true)

        post.reload
        expect(post.published).to be(true)
      end

      it 'works with idempotent operations' do
        post = Post.create!(title: 'Published Post', body: 'Content', published: true)

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
        post = Post.create!(title: 'Published Post', body: 'Content', published: true)
        expect(post.published).to be(true)

        patch "/api/v1/posts/#{post.id}/archive"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['post']['id']).to eq(post.id)
        expect(json['post']['published']).to be(false)

        post.reload
        expect(post.published).to be(false)
      end

      it 'handles idempotent custom actions' do
        post = Post.create!(title: 'Archived Post', body: 'Content', published: false)

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
          published: true
        )

        get "/api/v1/posts/#{post.id}/preview"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['post']).to be_present
        expect(json['post']['id']).to eq(post.id)
        expect(json['post']['title']).to eq('Test Post')
        expect(json['post']['body']).to eq('This is a long post body.')
        expect(json['post']['published']).to be(true)
      end

      it 'serializes resources with varying attribute values' do
        post = Post.create!(title: 'Short', body: 'Short body', published: false)

        get "/api/v1/posts/#{post.id}/preview"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['post']['body']).to eq('Short body')
      end

      it 'handles nil values in serialization' do
        post = Post.create!(title: 'No body', body: nil, published: false)

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
        Post.create!(title: 'Ruby Tutorial', body: 'Learn Ruby programming', published: true)
        Post.create!(title: 'Rails Guide', body: 'Learn Rails framework', published: true)
        Post.create!(title: 'Python Tutorial', body: 'Learn Python programming', published: false)
        Post.create!(title: 'JavaScript Basics', body: 'Learn JavaScript', published: true)
      end

      it 'routes to custom collection action with query params' do
        get '/api/v1/posts/search', params: { q: 'Ruby' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
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
        expect(json['ok']).to be(true)
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
            { title: 'Post 1', body: 'Body 1', published: true },
            { title: 'Post 2', body: 'Body 2', published: false },
            { title: 'Post 3', body: 'Body 3', published: true }
          ]
        }

        expect do
          post '/api/v1/posts/bulk_create', params: posts_params, as: :json
        end.to change(Post, :count).by(3)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['posts'].length).to eq(3)

        titles = json['posts'].map { |p| p['title'] }.sort
        expect(titles).to eq(['Post 1', 'Post 2', 'Post 3'])
      end

      it 'handles empty arrays in custom actions' do
        post '/api/v1/posts/bulk_create', params: { posts: [] }, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['posts']).to eq([])
      end

      it 'applies defaults to array elements' do
        posts_params = {
          posts: [
            { title: 'Post without published', body: 'Body' }
          ]
        }

        post '/api/v1/posts/bulk_create', params: posts_params, as: :json

        json = JSON.parse(response.body)
        expect(json['posts'][0]['published']).to be(false)
      end

      it 'handles missing params gracefully' do
        post '/api/v1/posts/bulk_create', params: {}, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['posts']).to eq([])
      end
    end
  end

  describe 'Interaction between standard and custom actions' do
    it 'works consistently with standard CRUD actions' do
      post = Post.create!(title: 'Test', body: 'Body', published: false)

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
      Post.create!(title: 'Ruby Post', body: 'Ruby content', published: true)
      Post.create!(title: 'Python Post', body: 'Python content', published: false)

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
    let!(:post_record) { Post.create!(title: 'Test Post', body: 'Body') }

    context 'archive action' do
      it 'validates boolean parameter types' do
        patch "/api/v1/posts/#{post_record.id}/archive", params: {
          notify_users: 'not-a-boolean'
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(false)

        notify_issue = json['issues'].find { |issue| issue['pointer']&.include?('notify_users') }
        expect(notify_issue).to be_present
        expect(notify_issue['code']).to eq('invalid_type')
      end

      it 'rejects unknown fields' do
        patch "/api/v1/posts/#{post_record.id}/archive", params: {
          unknown_field: 'value'
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        unknown_issue = json['issues'].find { |issue| issue['code'] == 'field_unknown' }
        expect(unknown_issue).to be_present
      end
    end
  end
end
