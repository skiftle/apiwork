# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI export pipeline', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  it 'includes openapi version' do
    expect(spec[:openapi]).to eq('3.1.0')
  end

  it 'includes info with title' do
    expect(spec[:info][:title]).to be_a(String)
  end

  it 'includes invoice paths' do
    expect(spec[:paths]).to have_key('/invoices')
    expect(spec[:paths]).to have_key('/invoices/{id}')
  end

  it 'includes component schemas' do
    schema_keys = spec[:components][:schemas].keys

    expect(schema_keys).to include('invoice', 'payment')
  end

  it 'serializes to valid JSON' do
    json = generator.serialize(spec, format: :json)

    expect { JSON.parse(json) }.not_to raise_error
  end

  it 'generates error responses for raises declarations' do
    show_operation = spec[:paths]['/invoices/{id}']['get']

    expect(show_operation[:responses]).to have_key(:'404')
  end

  it 'generates 422 response for create action' do
    create_operation = spec[:paths]['/invoices']['post']

    expect(create_operation[:responses]).to have_key(:'422')
  end

  it 'generates 204 no content for destroy' do
    receipt_destroy = spec[:paths]['/receipts/{id}']['delete']

    expect(receipt_destroy[:responses]).to eq({ '204': { description: 'No content' } })
  end
end
