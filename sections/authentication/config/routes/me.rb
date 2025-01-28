get '/me', to: redirect('/profile/edit')

namespace :me do
  resource :profile, only: %i[edit update]
end
