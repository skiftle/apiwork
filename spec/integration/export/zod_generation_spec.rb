# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zod Generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::Zod.new(path) }
  let(:output) { generator.generate }

  describe 'Zod output format' do
    it 'generates valid Zod schema declarations' do
      expect(output).to be_a(String)
      expect(output).to include('import { z } from')
    end

    it 'generates schema definitions using z.object' do
      expect(output).to include('z.object(')
    end

    it 'exports schemas' do
      expect(output).to include('export const')
    end
  end

  describe 'Resource schemas' do
    it 'generates Post schema' do
      expect(output).to match(/export const \w*[Pp]ost\w* = z\.object/)
    end

    it 'generates Comment schema' do
      expect(output).to match(/export const \w*[Cc]omment\w* = z\.object/)
    end
  end

  describe 'Property types' do
    it 'generates string properties with z.string()' do
      expect(output).to include('z.string()')
    end

    it 'generates boolean properties with z.boolean()' do
      expect(output).to include('z.boolean()')
    end

    it 'generates integer properties with z.number()' do
      expect(output).to include('z.number()')
    end

    it 'generates optional properties correctly' do
      expect(output).to include('.optional()')
    end

    it 'generates nullable properties correctly' do
      expect(output).to include('.nullable()')
    end
  end

  describe 'Array types' do
    it 'generates array schemas with z.array()' do
      expect(output).to include('z.array(')
    end
  end

  describe 'Enum types' do
    it 'generates enums with z.enum()' do
      expect(output).to include('z.enum(')
    end

    it 'includes enum values' do
      expect(output).to match(/z\.enum\(\[['"][^'"]+['"](, ['"][^'"]+['"])*\]\)/)
    end
  end

  describe 'Request/Response schemas' do
    it 'generates request schemas' do
      expect(output).to match(/Request/)
    end

    it 'generates response schemas' do
      expect(output).to match(/Response/)
    end
  end

  describe 'Filter schemas' do
    it 'generates filter schemas for resources' do
      expect(output).to match(/Filter/)
    end
  end

  describe 'Payload schemas' do
    it 'generates create payload schemas' do
      expect(output).to match(/CreatePayload|Create.*Payload/)
    end

    it 'generates update payload schemas' do
      expect(output).to match(/UpdatePayload|Update.*Payload/)
    end
  end

  describe 'Key transformation options' do
    context 'with camelCase transformation' do
      let(:generator) { Apiwork::Export::Zod.new(path, key_format: :camel) }

      it 'transforms property names to camelCase' do
        expect(output).to match(/createdAt:/)
      end
    end

    context 'with keep (no transformation)' do
      let(:generator) { Apiwork::Export::Zod.new(path, key_format: :keep) }

      it 'keeps property names unchanged' do
        expect(output).to match(/created_at:/)
      end
    end
  end

  describe 'Zod syntax validity' do
    it 'properly closes all parentheses' do
      open_parens = output.scan(/\(/).count
      close_parens = output.scan(/\)/).count
      expect(open_parens).to eq(close_parens)
    end

    it 'has valid export statements' do
      expect(output.lines.grep(/^export const/)).to all(match(/^export const \w+[:\s]/))
    end

    it 'imports from zod' do
      expect(output).to match(/import \{ z \} from ['"]zod['"]/)
    end
  end
end
