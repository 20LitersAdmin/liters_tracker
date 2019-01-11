# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'users#homepage'
  get 'reports', to: 'users#reports'

  resources :updates
  resources :plans
  resources :targets
  resources :contracts
  resources :technologies
  resources :districts
  resources :sectors
  resources :cells
  resources :villages
  resources :facilities

  devise_for :users

  resources :users do
    get 'homepage', on: :member
  end
end
