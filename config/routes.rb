# frozen_string_literal: true

Rails.application.routes.draw do
  concern :with_datatable do
    post 'datatable', on: :collection
  end


  root to: 'dashboard#index'

  resources :dashboard, only: %i[index]

  get 'dashboard/handler', to: 'dashboard#handler', as: 'dashboard_handler'
  get 'dashboard/planner', to: 'dashboard#planner', as: 'dashboard_planner'

  get 'stats', to: 'dashboard#stats_json', as: 'stats'

  resources :reports, except: %i[new], concerns: [:with_datatable] do
    get 'dttb_index', on: :collection
  end

  resources :contracts do
    resources :targets, only: %i[new create edit update destroy]
    resources :plans, except: %i[new index] do
      get 'dttb_index', on: :collection
    end
    get 'select', on: :member # sector selection for plans
    get 'plan', on: :member
  end

  resources :technologies

  resources :countries do
    get 'hidden', on: :collection
    get 'make_visible', on: :member
  end

  resources :districts do
    get 'hidden', on: :collection
    get 'children', on: :member
    get 'make_visible', on: :member
  end
  resources :sectors do
    get 'hidden', on: :collection
    get 'select', on: :collection # sector selection for reports
    get 'report', on: :member
    get 'children', on: :member
    get 'make_visible', on: :member
  end
  resources :cells do
    get 'hidden', on: :collection
    get 'children', on: :member
    get 'make_visible', on: :member
  end
  resources :villages do
    get 'hidden', on: :collection
    get 'children', on: :member
    get 'make_visible', on: :member
  end
  resources :facilities do
    get 'reassign', on: :member
    get 'reassign_to', on: :member
  end

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
  get 'geography', to: 'users#geography', as: 'geography'

  get 'monthly', to: 'monthly#index'
  post 'monthly/redirector', to: 'monthly#redirector', as: 'monthly_redirector'
  get ':year/:month', to: 'monthly#show', as: 'monthly_w_date', constraints: { year: /[0-9]{4}/, month: /[0-9]{1,2}/ }

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
