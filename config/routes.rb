Rails.application.routes.draw do
  resources :charts, only: [:index] do
    get 'tag_data', on: :collection
    get 'calls_by_date', on: :collection
    get 'first_vs_repeat', on: :collection
    get 'generate_pie_chart', on: :collection
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'application#hello'


end
