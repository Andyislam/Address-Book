Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # get 'welcome/index'
  # You can have the root of your site routed with "root"
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }


  resources :welcome
  resources :contacts
  root 'welcome#index'

  match "/update_contact" => "contacts#update_contact", as: "update_contact", via: [:get, :post]

end
