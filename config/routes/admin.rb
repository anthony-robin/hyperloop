get '/admin', to: redirect('/admin/dashboard')

namespace :admin do
  resource :dashboard, only: :show
  resources :users, only: :index
end

resolve('Dashboard') { route_for(:dashboard) }
