Rails.application.routes.draw do
  root 'home#index'
  resource :discount_setting, only: [:new, :create]

  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
