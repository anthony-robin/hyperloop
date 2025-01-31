get '/admin', to: redirect('/admin/dashboard')

namespace :admin do
  resource :dashboard, only: :show
  resources :users, except: :show
end

resolve('Dashboard') { route_for(:dashboard) }
