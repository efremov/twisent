Rails.application.routes.draw do
  
  devise_for :users, :controllers => { registrations: 'registrations', sessions: "sessions", omniauth_callbacks: 'omniauth_callbacks'}
  resources :documents, only: [:index, :destroy, :edit, :update]
  
  devise_scope :user do
    root to: "devise/sessions#new"  
  end
  
end
