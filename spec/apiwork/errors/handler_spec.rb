# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Errors::Handler do
  let(:error) { StandardError.new('Test error message') }
  let(:context) { { field: :status, operator: :invalid } }

  describe '.handle' do
    context 'when error_handling_mode is :raise' do
      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:raise)
      end

      it 'raises the error' do
        expect {
          described_class.handle(error, context: context)
        }.to raise_error(StandardError, 'Test error message')
      end
    end

    context 'when error_handling_mode is :log' do
      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:log)
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:warn).with(/Apiwork Error: StandardError - Test error message/)
        allow(Rails.logger).to receive(:debug)  # Allow debug calls (may not happen in test env)

        result = described_class.handle(error, context: context)
        expect(result).to be_nil
      end

      it 'logs without context when context is empty' do
        expect(Rails.logger).to receive(:warn).with(/Apiwork Error/)
        allow(Rails.logger).to receive(:debug)  # Allow debug calls

        result = described_class.handle(error, context: {})
        expect(result).to be_nil
      end
    end

    context 'when error_handling_mode is :silent' do
      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:silent)
      end

      it 'silently returns nil without logging' do
        expect(Rails.logger).not_to receive(:warn)
        expect(Rails.logger).not_to receive(:debug)

        result = described_class.handle(error, context: context)
        expect(result).to be_nil
      end
    end

    context 'when error_handling_mode is unknown' do
      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:unknown_mode)
      end

      it 'defaults to silent mode and returns nil' do
        expect(Rails.logger).not_to receive(:warn)
        expect(Rails.logger).not_to receive(:debug)

        result = described_class.handle(error, context: context)
        expect(result).to be_nil
      end
    end

    context 'when Rails is not defined' do
      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:log)
      end

      it 'checks for Rails before logging' do
        # Stub defined? check to return false
        allow(described_class).to receive(:defined?).with(::Rails).and_return(false)

        # Should not raise error, just return nil
        expect {
          result = described_class.handle(error, context: context)
          expect(result).to be_nil
        }.not_to raise_error
      end
    end
  end

  describe 'with different error types' do
    context 'with Apiwork::PaginationError' do
      let(:pagination_error) do
        Apiwork::PaginationError.new(
          code: :invalid_page_number,
          detail: 'page[number] must be >= 1',
          path: [:page, :number]
        )
      end

      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:raise)
      end

      it 'raises the Apiwork error' do
        expect {
          described_class.handle(pagination_error, context: { page_number: 0 })
        }.to raise_error(Apiwork::PaginationError)
      end
    end

    context 'with Apiwork::FilterError' do
      let(:filter_error) do
        Apiwork::FilterError.new(
          code: :invalid_operator,
          detail: 'Invalid operator for field',
          path: [:filter, :status]
        )
      end

      before do
        allow(Apiwork.configuration).to receive(:error_handling_mode).and_return(:log)
      end

      it 'logs the filter error' do
        expect(Rails.logger).to receive(:warn).with(/Apiwork Error: Apiwork::FilterError/)

        described_class.handle(filter_error, context: { operator: :bad_op })
      end
    end
  end
end
