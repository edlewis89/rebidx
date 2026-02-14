Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :listings do
    resources :bids, only: [:new, :create]
  end

  resources :bids, only: [] do
    resource :payment, only: [:new, :create]
    resource :ratings, only: [:new, :create]
    member do
      patch :accept
      patch :reject
      patch :withdrawn
      patch :complete
    end
  end

  namespace :homeowner do
    get :dashboard, to: "dashboard#index"
    # Add this:
    resources :listings, only: [:index, :show, :edit, :update, :destroy]
  end

  namespace :provider do
    resource :onboarding, only: [:show, :update]
    get :dashboard, to: "dashboard#index"
  end

  namespace :admin do
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index", as: :dashboard

    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :verifications, only: [:index, :show, :update]
    resources :listings
    resources :license_types
    resources :advertisements
    resources :memberships
    resources :service_provider_profiles, only: [:index] do
      patch :verify, on: :member
    end
    resources :service_provider_profiles, only: [:show] do
      resources :ratings, only: [:create]
    end
  end

  resources :memberships, only: [:index]
  resources :provider_memberships, only: [:index]
  resource :subscription, only: [:show, :update, :destroy]
  resource :profile, only: [:show, :edit, :update]

  resources :notifications, only: [:index] do
    member { patch :mark_as_read }
    collection { post :mark_all_read }
  end

  resources :payments, only: [] do
    collection do
      post :create_membership_payment
      post :create_listing_payment
      get :success
      get :cancel
      post :webhook
    end
  end

  # namespace :admin do
  #   # Admin root goes to dashboard#index
  #   root to: "dashboard#index"
  #
  #   # Explicit dashboard route (optional, since root already goes there)
  #   get "dashboard", to: "dashboard#index", as: :dashboard
  #
  #   # Service provider profile management
  #   resources :service_provider_profiles, only: [:index] do
  #     patch :verify, on: :member
  #   end
  #   resources :listings, only: [:index, :show, :edit, :update, :destroy] # <-- this
  #   resources :users, only: [:index, :show, :edit, :update, :destroy]
  # end
  # API routes
  namespace :api, defaults: { format: :json } do
    devise_scope :user do
      post '/login', to: 'sessions#create'
      post '/signup', to: 'registrations#create'  # <-- add this
    end
    resources :listings, only: [:index, :show, :create, :update, :destroy]
    resources :bids, only: [:index, :create]

    get "listings/nearby", to: "listings#nearby"
    get "providers/nearby", to: "providers#nearby"
  end

  get  "/choose-role", to: "roles#new",    as: :choose_role
  post "/choose-role", to: "roles#create"
  post "/webhooks/stripe", to: "webhooks#stripe"
  root "listings#index"
end
