Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'users/registrations'}
  root 'home#show'
  
  resources :users, only: [:show] do
    resources :posts, only: [:index, :new, :create, :destroy]
  end
end
