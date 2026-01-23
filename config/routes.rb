Rails.application.routes.draw do

  devise_for :users

<<<<<<< HEAD
  root "pages#home"
  post "/", to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :chats, only: [:index, :show, :destroy] do
=======

  root to: "pages#home"
  post "/", to: "pages#home"


  get "up" => "rails/health#show", as: :rails_health_check


  resources :chats, only: [:show, :index, :destroy] do
    resources :messages, only: [:create]
>>>>>>> 6e7cb94f7a1ece5292441043ce6669827229dcf9
    member do
      get :reveal
    end

    resources :messages, only: [:create]
  end


  get 'chats/show'
end
