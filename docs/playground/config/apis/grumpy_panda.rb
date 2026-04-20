# frozen_string_literal: true

Apiwork::API.define '/grumpy_panda' do
  key_format :camel

  export :openapi
  export :apiwork

  resources :activities
end
