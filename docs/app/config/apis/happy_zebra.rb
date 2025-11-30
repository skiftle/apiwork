# frozen_string_literal: true

Apiwork::API.draw '/happy-zebra' do
  enum :status, values: %w[draft published archived]
end
