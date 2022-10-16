Rails.application.routes.draw do
  devise_for :users
  root 'home#show'
  get 'posts/index' 
end
