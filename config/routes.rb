# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'users#homepage'
  get 'data', to: 'users#data'

  resources :reports do
    get 'batch_process', on: :collection
  end
  resources :contracts do
    get 'all', on: :collection
  end
  resources :plans
  resources :targets

  resources :technologies do
    get 'all', on: :collection
  end

  resources :districts do
    get 'all', on: :collection
  end
  resources :sectors do
    get 'select', on: :collection
    get 'report', on: :member
  end
  resources :cells
  resources :villages
  resources :facilities

  devise_for :users

  resources :users do
    get 'homepage', on: :member
  end
end
