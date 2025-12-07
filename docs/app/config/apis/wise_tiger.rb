# frozen_string_literal: true

Apiwork::API.draw '/wise_tiger' do
  key_format :camel

  info do
    title 'Project Management API'
    version '1.0.0'
    description 'API for managing projects with I18n-powered documentation'
  end

  spec :openapi
  spec :zod
  spec :typescript

  resources :projects
end
