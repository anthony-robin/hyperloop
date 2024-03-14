get '/admin', to: redirect('/admin/dashboard')

namespace :admin do
  resource :dashboard, only: :show
  resources :users, only: %i[index new create edit update destroy]
end

resolve('Dashboard') { route_for(:dashboard) }
