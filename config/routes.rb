Rails.application.routes.draw do
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'signup', to: 'registrations#create'
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
      end

      resources :commodities, only: [:create, :index, :show]
      post 'commodity/bid', to: 'bids#create'

      # resources :bids, only: [:show, :update]
    end
  end
end
