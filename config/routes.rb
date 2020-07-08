# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'dashboard#index'

  resources :dashboard, only: %i[index]

  get 'dashboard/handler', to: 'dashboard#handler', as: 'dashboard_handler'
  get 'dashboard/planner', to: 'dashboard#planner', as: 'dashboard_planner'

  get 'stats', to: 'dashboard#stats_json', as: 'stats'

  resources :reports, except: %i[new] do
    get 'dttb_index', on: :collection
  end

  resources :contracts do
    resources :targets, only: %i[new create edit update destroy]
    resources :plans do
      get 'dttb_index', on: :collection
    end
  end

  resources :technologies

  resources :countries
  resources :districts do
    get 'children', on: :member
  end
  resources :sectors do
    get 'select', on: :collection
    get 'report', on: :member
    get 'children', on: :member
  end
  resources :cells do
    get 'children', on: :member
  end
  resources :villages do
    get 'children', on: :member
  end
  resources :facilities

  resources :stories do
    get 'image', on: :member
    patch 'upload_image', on: :member
    get  'rotate_image', on: :member
    get  'destroy_image', on: :member
  end

  devise_for :users

  resources :users
  get 'data', to: 'users#data', as: 'data'
  get 'data_filter', to: 'users#data_filter', as: 'data_filter'

  get 'monthly', to: 'monthly#index'
  post 'monthly/redirector', to: 'monthly#redirector', as: 'monthly_redirector'
  get ':year/:month', to: 'monthly#show', as: 'monthly_w_date', constraints: { year: /[0-9]{4}/, month: /[0-9]{1,2}/ }
end
