Rails.application.routes.draw do
  root to: 'homes#show'

  get '/sessions', to: redirect('/sessions/new')

  resource :sessions, only: %i[new create destroy]
  resources :password_resets, only: %i[new create edit update]

  draw :me
  draw :admin

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
