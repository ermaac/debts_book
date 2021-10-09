Rails.application.routes.draw do
  root to: 'accounts#index'
  resources :accounts, only: %i[index]

  namespace :api do
    namespace :v1 do
      post :transfer, to: 'transfer_transactions#create'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
