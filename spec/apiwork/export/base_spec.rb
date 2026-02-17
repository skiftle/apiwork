# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::Base do
  describe '.export_name' do
    it 'returns the export name' do
      export_class = Class.new(described_class) do
        export_name :invoice
      end

      expect(export_class.export_name).to eq(:invoice)
    end

    it 'returns nil when not set' do
      export_class = Class.new(described_class)

      expect(export_class.export_name).to be_nil
    end
  end

  describe '.file_extension' do
    it 'returns the file extension' do
      export_class = Class.new(described_class) do
        output :string
        file_extension '.ts'
      end

      expect(export_class.file_extension).to eq('.ts')
    end

    it 'returns nil when not set' do
      export_class = Class.new(described_class)

      expect(export_class.file_extension).to be_nil
    end

    it 'raises ConfigurationError when output is hash' do
      expect do
        Class.new(described_class) do
          output :hash
          file_extension '.json'
        end
      end.to raise_error(Apiwork::ConfigurationError, /file_extension not allowed/)
    end
  end

  describe '.output' do
    it 'returns the output' do
      export_class = Class.new(described_class) do
        output :hash
      end

      expect(export_class.output).to eq(:hash)
    end

    it 'returns nil when not set' do
      export_class = Class.new(described_class)

      expect(export_class.output).to be_nil
    end

    it 'raises ArgumentError when type is invalid' do
      expect do
        Class.new(described_class) do
          output :invalid
        end
      end.to raise_error(ArgumentError, /output must be :hash or :string/)
    end
  end
end
