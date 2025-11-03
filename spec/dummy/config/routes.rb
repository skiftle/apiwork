Rails.application.routes.draw do
  # Mount Apiwork engine
  mount Apiwork.routes => '/'
end
