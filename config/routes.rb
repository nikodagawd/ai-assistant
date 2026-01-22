Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  post "/", to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :chats, only: [:show, :index, :destroy] do
    member do
      get :reveal
    end
  end
end
