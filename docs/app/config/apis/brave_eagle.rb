# frozen_string_literal: true

Apiwork::API.draw '/brave-eagle' do
  key_format :camel

  info do
    title 'Task Management API'
    version '1.0.0'
    description 'API for managing tasks and projects'

    contact do
      name 'API Support'
      email 'support@example.com'
    end

    license do
      name 'MIT'
      url 'https://opensource.org/licenses/MIT'
    end
  end

  spec :openapi
  spec :zod
  spec :typescript

  resources :tasks do
    member do
      patch :archive
    end
  end
end
