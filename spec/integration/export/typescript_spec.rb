# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TypeScript export pipeline', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::TypeScript.new(path) }
  let(:output) { generator.generate }

  it 'generates non-empty output' do
    expect(output).to be_a(String)
    expect(output.length).to be_positive
  end

  it 'includes invoice interface' do
    expect(output).to include('export interface Invoice')
  end

  it 'includes invoice status enum type' do
    expect(output).to include('export type InvoiceStatus')
  end

  it 'includes action request body type' do
    expect(output).to include('InvoicesCreateRequestBody')
  end

  it 'includes payment interface' do
    expect(output).to include('export interface Payment')
  end
end
