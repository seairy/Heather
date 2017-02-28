Rails.application.routes.draw do
  root 'dashboard#index'
  resources :countries
  resources :employees do
    resources :travel_expenses
    resources :room_expenses
    resources :medical_expenses
    resources :title_ranges do
      collection do
        delete :truncate
      end
    end
    resources :spouse_ranges do
      collection do
        delete :truncate
      end
    end
    member do
      get :payroll
    end
  end
  resources :travel_expenses
  resources :room_expenses
  resources :medical_expenses
  resources :title_ranges
  resources :spouse_ranges
  get :dashboard, to: 'dashboard#index', as: :dashboard
  get :sign_in, to: 'sessions#new', as: :sign_in
  post :sign_in, to: 'sessions#create'
  get :sign_out, to: 'sessions#destroy', as: :sign_out
end
