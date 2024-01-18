module Admin
  class UsersController < ApplicationController
    # @route GET /admin/users (admin_users)
    def index
      authorize! User

      @pagy, @users = pagy(User.all)
    end
  end
end
