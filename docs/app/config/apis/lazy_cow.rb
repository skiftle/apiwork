# frozen_string_literal: true

Apiwork::API.draw '/lazy_cow' do
  key_format :camel

  resource :status, only: [] do
    collection do
      get :health
      get :stats
    end
  end
end
