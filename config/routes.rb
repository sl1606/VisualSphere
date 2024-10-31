Rails.application.routes.draw do
  resources :dashboards
  resources :charts do
    collection do
      get :get_chart_type
    end
  end
  resources :collections, only: [:show, :destroy] do
    collection do
      get :get_variables
      post :save_variables
      put :update_variables
      put :update_chart_type
    end
  end
  resources :db_connections
  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  root 'db_connections#index'
  resources :sessions, only: [:new, :create]
  resources :home, only: [:new, :create] do
    collection do
      get :success
      get :fail
      get :mysql_new
      post :mysql_create
    end
  end
end
