class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  layout 'session'

  # @route GET /password_resets/new (new_password_reset)
  def new
    redirect_to root_path if logged_in?
  end

  # @route POST /password_resets (password_resets)
  def create
    if user_params[:email].present?
      @user = User.find_by(email: user_params[:email])

      if @user
        @user.deliver_reset_password_instructions!

        redirect_to(new_sessions_path, notice: 'Les instructions pour réinitialiser votre mot de passe ont été envoyées.')
      else
        flash[:alert] = "L'email renseigné n'est pas valide"

        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = 'Veuillez renseigner votre email'

      render :new, status: :unprocessable_entity
    end
  end

  # @route GET /password_resets/:id/edit (edit_password_reset)
  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    redirect_to new_sessions_path if @user.blank?
  end

  # @route PATCH /password_resets/:id (password_reset)
  # @route PUT /password_resets/:id (password_reset)
  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      redirect_to new_sessions_path
      return
    end

    @user.password_confirmation = user_params[:password_confirmation]

    if @user.change_password(user_params[:password])
      redirect_to(new_sessions_path, notice: 'Le mot de passe a été mis à jour avec succès.')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end
end
