Rails.application.routes.draw do
  resources :bnbs, only: [:index], path: "bed_and_breakfasts"
  resources :votes, only: [:create]
end
