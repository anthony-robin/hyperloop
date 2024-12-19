Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: '/jobs'
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root to: 'homes#show'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker

  get '/sessions', to: redirect('/sessions/new')

  resource :sessions, only: %i[new create destroy]
  resources :password_resets, only: %i[new create edit update]

  draw :me
  draw :admin
end
