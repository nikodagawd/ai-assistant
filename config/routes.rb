Rails.application.routes.draw do
  root "pages#home"     
  post "/" => "pages#home" 
end
