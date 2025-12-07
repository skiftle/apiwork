# frozen_string_literal: true

Apiwork::API.draw '/grumpy-panda' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :activities
end
