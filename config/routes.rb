Rails.application.routes.draw do
  resources :charts, only: [:index]

  root 'charts#index'


end
