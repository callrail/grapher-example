Rails.application.routes.draw do
  resources :charts, only: [:index] do
    get 'tagdata', on: :collection
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'application#hello'


end
