Rails.application.routes.draw do
  devise_for :users

  root "pages#home"
  post "/", to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :chats, only: [:index, :show, :destroy] do
    member do
      get :reveal
    end
    resources :messages, only: [:create]
  end
end
