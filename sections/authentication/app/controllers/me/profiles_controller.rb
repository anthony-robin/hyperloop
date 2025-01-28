module Me
  class ProfilesController < ApplicationController
    # @route GET /me/profile/edit (edit_me_profile)
    def edit
    end

    # @route PATCH /me/profile (me_profile)
    # @route PUT /me/profile (me_profile)
    def update
      if current_user.update(profile_params)
        redirect_to edit_me_profile_path, notice: t('.notice')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.expect(user: %i[first_name last_name email_address avatar])
    end
  end
end
