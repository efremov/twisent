Rails.application.routes.draw do
  
  devise_for :users, :controllers => { registrations: 'registrations', sessions: "sessions", omniauth_callbacks: 'omniauth_callbacks'}

  
  root to: "pages#landing"  
  resources :users, only: [:show] 
  
  resources :documents, only: [:index]

  resources :companies do
    resources :documents, only: [:index, :destroy, :edit, :update]
    get "api" => "companies#api", on: :member
    get "test" => "accuracy_tests#show", on: :member
    put "test" => "accuracy_tests#update", on: :member
  end

  resources :tickets, only: [:new, :index, :create]


  resources :questions, only: [:new, :create, :edit, :update]
  get "faq" => "questions#index"


end
