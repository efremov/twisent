Rails.application.routes.draw do
  
  resources :documents, only: [:index, :destroy, :edit, :update]
  # root 'welcome#index'

end
