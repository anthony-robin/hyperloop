module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: %i[edit update destroy]

    # @route GET /admin/users (admin_users)
    def index
      authorize! User

      @pagy, @users = pagy(User.order(created_at: :desc))
    end

    # @route GET /admin/users/new (new_admin_user)
    def new
      authorize! User

      @user = User.new
    end

    # @route POST /admin/users (admin_users)
    def create
      authorize! User

      @user = User.new(user_params) do |user|
        random_password = SecureRandom.hex

        user.role = :standard
        user.password = random_password
        user.password_confirmation = random_password
      end

      if @user.save
        redirect_to admin_users_path, notice: "L'utilisateur a bien été créé, un email lui a été envoyé"
      else
        render :new, status: :unprocessable_entity
      end
    end

    # @route GET /admin/users/:id/edit (edit_admin_user)
    def edit
      authorize! @user
    end

    # @route PATCH /admin/users/:id (admin_user)
    # @route PUT /admin/users/:id (admin_user)
    def update
      authorize! @user

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "L'utilisateur a bien été modifié"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # @route DELETE /admin/users/:id (admin_user)
    def destroy
      authorize! @user

      @user.destroy

      redirect_to admin_users_path, notice: "L'utilisateur a bien été supprimé"
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :first_name, :last_name, :email_address,
        :password, :password_confirmation
      )
    end
  end
end
