# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sorbus export pipeline', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Sorbus.new(path) }
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

  it 'includes contract definition' do
    expect(output).to include('export const contract = {')
    expect(output).to include('} as const;')
  end

  it 'includes endpoint paths' do
    expect(output).to include("path: '/invoices'")
  end

  it 'includes error reference' do
    expect(output).to include('error: ErrorSchema')
  end
end
