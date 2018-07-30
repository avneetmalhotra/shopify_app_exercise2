Rails.application.routes.draw do
  root 'home#index'
  resources :settings, only: [:edit, :update] do
    member do
      patch 'modify_theme'
    end
  end

  mount ShopifyApp::Engine, at: '/'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
