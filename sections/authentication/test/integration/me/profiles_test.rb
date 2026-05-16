require 'test_helper'

module Me
  class ProfilesTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:admin)

      sign_in_as(@user)
    end

    test 'should get edit profile' do
      get '/me/profile/edit'

      assert_response :success
    end

    test 'should update profile with valid data' do
      patch '/me/profile', params: {
        user: {
          first_name: 'John'
        }
      }

      assert_redirected_to '/me/profile/edit'
      assert_equal I18n.t('me.profiles.update.notice'), flash[:notice]
    end

    test 'should not update profile with invalid data' do
      patch '/me/profile', params: {
        user: {
          first_name: nil
        }
      }

      assert_response :unprocessable_content
    end
  end
end
