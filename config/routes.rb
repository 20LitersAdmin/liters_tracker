# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'dashboard#index'
  get 'data', to: 'users#data'

  resources :dashboard, only: %i[index]

  get 'dashboard/handler', to: 'dashboard#handler', as: 'dashboard_handler'
  get 'dashboard/planner', to: 'dashboard#planner', as: 'dashboard_planner'

  resources :reports do
    post 'batch_process', on: :collection
  end
  resources :contracts
  resources :plans
  resources :targets

  resources :technologies

  resources :countries
  resources :districts
  resources :sectors do
    get 'select', on: :collection
    get 'report', on: :member
    get 'new_facility', on: :member
  end
  resources :cells
  resources :villages
  resources :facilities do
    get 'village_finder', on: :collection
    get 'facility_error', on: :member
  end

  resources :stories

  devise_for :users

  resources :users do
    get 'homepage', on: :member
  end

  get 'monthly', to: 'monthly#index'
  post 'monthly/redirector', to: 'monthly#redirector', as: 'monthly_redirector'
  get ':year/:month', to: 'monthly#show', as: 'monthly_w_date'
end
