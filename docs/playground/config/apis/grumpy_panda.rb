# frozen_string_literal: true

Apiwork::API.draw '/grumpy_panda' do
  key_format :camel

  resources :activities
end
