# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod export pipeline', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  it 'generates output with zod import' do
    expect(output).to include("import { z } from 'zod'")
  end

  it 'includes invoice schema' do
    expect(output).to include('InvoiceSchema')
    expect(output).to include('z.object(')
  end

  it 'includes invoice status enum schema' do
    expect(output).to include('InvoiceStatusSchema = z.enum(')
  end

  it 'includes action request body schema' do
    expect(output).to include('InvoicesCreateRequestBodySchema')
  end

  it 'includes response body schema' do
    expect(output).to include('InvoicesShowResponseBodySchema')
  end
end
