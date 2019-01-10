# frozen_string_literal: true

Rails.application.routes.draw do
  resources :plans
  resources :targets
  resources :contracts
  resources :technologies
  resources :districts
  resources :sectors
  resources :cells
  resources :villages
  resources :facilities
  root to: 'users#homepage'

  devise_for :users

  resources :users do
    get 'homepage', on: :member
  end
end
