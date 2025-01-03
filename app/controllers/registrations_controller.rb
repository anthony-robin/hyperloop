class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  # @route GET /registration/new (new_registration)
  def new
    @user = User.new
  end

  # @route POST /registration (registration)
  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: 'Successfully signed up!'
    else
      render :new
    end
  end

  private

  def user_params
    params.expect(user: %i[email_address password password_confirmation])
  end
end
