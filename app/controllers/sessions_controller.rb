class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  layout 'session'

  # @route GET /sessions/new (new_sessions)
  def new
    redirect_to root_path if logged_in?
  end

  # @route POST /sessions (sessions)
  def create
    @user = login(session_params[:email], session_params[:password], session_params[:remember])

    if @user
      redirect_to root_path
    else
      flash.now[:alert] = 'Erreur lors de la connexion'

      render :new, status: :unauthorized
    end
  end

  # @route DELETE /sessions (sessions)
  def destroy
    logout

    redirect_to new_sessions_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password, :remember)
  end
end
