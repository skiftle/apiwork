# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI operation generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  describe 'Operation IDs' do
    it 'generates operationId for index action' do
      invoices_index = spec[:paths]['/invoices']['get']

      expect(invoices_index[:operationId]).to eq('invoices_index')
    end

    it 'generates custom operationId when specified' do
      invoices_destroy = spec[:paths]['/invoices/{id}']['delete']

      expect(invoices_destroy[:operationId]).to eq('deleteInvoice')
    end
  end

  describe 'Request body' do
    it 'generates request body for create action' do
      create_op = spec[:paths]['/invoices']['post']

      expect(create_op[:requestBody][:content]).to have_key(:'application/json')
    end

    it 'generates request body for update action' do
      update_op = spec[:paths]['/invoices/{id}']['patch']

      expect(update_op[:requestBody][:content]).to have_key(:'application/json')
    end
  end

  describe 'Response schema' do
    it 'generates 200 response for show action' do
      show_op = spec[:paths]['/invoices/{id}']['get']

      expect(show_op[:responses]).to have_key(:'200')
      expect(show_op[:responses][:'200'][:content]).to have_key(:'application/json')
    end

    it 'generates 200 response for index action' do
      index_op = spec[:paths]['/invoices']['get']

      expect(index_op[:responses]).to have_key(:'200')
    end
  end

  describe 'Query parameters' do
    it 'generates query parameters for search action' do
      search_op = spec[:paths]['/invoices/search']['get']
      query_params = search_op[:parameters].select { |param| param[:in] == 'query' }

      expect(query_params).to be_present
    end
  end

  describe 'Path parameters' do
    it 'generates path parameter for member actions' do
      show_op = spec[:paths]['/invoices/{id}']['get']
      id_param = show_op[:parameters].find { |param| param[:name] == 'id' }

      expect(id_param[:in]).to eq('path')
      expect(id_param[:required]).to be(true)
      expect(id_param[:schema]).to eq({ type: 'string' })
    end
  end

  describe 'Error responses' do
    it 'generates error responses for raises declarations' do
      show_op = spec[:paths]['/invoices/{id}']['get']

      expect(show_op[:responses]).to have_key(:'404')
    end

    it 'generates unprocessable entity for create action' do
      create_op = spec[:paths]['/invoices']['post']

      expect(create_op[:responses]).to have_key(:'422')
    end
  end

  describe 'Deprecated operation' do
    it 'marks destroy action as deprecated' do
      invoices_destroy = spec[:paths]['/invoices/{id}']['delete']

      expect(invoices_destroy[:deprecated]).to be(true)
    end
  end

  describe 'Tags' do
    it 'includes tags on tagged actions' do
      invoices_index = spec[:paths]['/invoices']['get']

      expect(invoices_index[:tags]).to include(:invoices, :public)
    end
  end

  describe 'Summary and description' do
    it 'includes summary on index action' do
      invoices_index = spec[:paths]['/invoices']['get']

      expect(invoices_index[:summary]).to eq('List all invoices')
    end

    it 'includes description on index action' do
      invoices_index = spec[:paths]['/invoices']['get']

      expect(invoices_index[:description]).to eq('Returns a paginated list of all invoices')
    end
  end
end
