Rails.application.routes.draw do
  devise_for :users, skip: :all

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'signup', to: 'registrations#create'
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
      end

      post 'commodity/list', to: 'commodities#create'
      get 'commodity/list', to: 'commodities#index'
      post 'commodity/re-list', to: 'commodities#re_list'
      post 'commodity/bid', to: 'bids#create'
      post 'commodity/re-bid', to: 'bids#re_bid'
      get 'commodity/:id/bids', to: 'bids#index'
      get 'commodity/my-commodities', to: 'commodities#my_commodities'
    end
  end
end
