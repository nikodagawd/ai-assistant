Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  post "/", to: "pages#home"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # For redirect to home after login/logout
  # Defines the root path route ("/")
  # root "posts#index"
  Rails.application.routes.draw do
    get 'chats/show'
    devise_for :users
    root to: "pages#home"
    post "/", to: "pages#home"
    get "up" => "rails/health#show", as: :rails_health_check
    resources :chats, only: [:show, :index] do
      resources :messages, only: [:create]
    end
  get "up" => "rails/health#show", as: :rails_health_check

  resources :chats, only: [:show, :index, :destroy] do
    member do
      get :reveal
    end
  end
end
