# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'users#homepage'
  get 'data', to: 'users#data'

  resources :reports do
    post 'batch_process', on: :collection
  end
  resources :contracts
  resources :plans
  resources :targets

  resources :technologies

  resources :districts
  resources :sectors do
    get 'select', on: :collection
    get 'report', on: :member
  end
  resources :cells
  resources :villages
  resources :facilities do
    get 'village_finder', on: :collection
  end

  devise_for :users

  resources :users do
    get 'homepage', on: :member
  end
end
