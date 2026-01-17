# frozen_string_literal: true

Apiwork::API.define '/wise_tiger' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  info do
    title 'Project Management API'
    version '1.0.0'
    description 'API for managing projects with I18n-powered documentation'
  end

  resources :projects
end
