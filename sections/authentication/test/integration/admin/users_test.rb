require 'test_helper'

module Admin
  class UsersTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @standard_user = users(:standard)
      @super_admin = users(:super_admin)
    end

    test 'should get index as admin' do
      sign_in_as(@admin)

      get '/admin/users'

      assert_response :success
    end

    test 'should redirect index for standard user' do
      sign_in_as(@standard_user)

      get '/admin/users'

      assert_redirected_to root_url
      assert_equal I18n.t('action_policy.default'), flash[:alert]
    end

    test 'should redirect index when unauthenticated' do
      get '/admin/users'

      assert_redirected_to new_session_url
    end

    test 'should get new as admin' do
      sign_in_as(@admin)

      get '/admin/users/new'

      assert_response :success
    end

    test 'should create user' do
      sign_in_as(@admin)

      assert_difference('User.count') do
        post '/admin/users', params: {
          user: {
            first_name: 'John',
            last_name: 'Doe',
            email_address: 'john@test.com',
            role: 'standard'
          }
        }
      end

      assert_redirected_to admin_users_url
      assert_equal I18n.t('admin.users.create.notice'), flash[:notice]
    end

    test 'should not create user with invalid params' do
      sign_in_as(@admin)

      assert_no_difference('User.count') do
        post '/admin/users', params: {
          user: {
            first_name: ''
          }
        }
      end

      assert_response :unprocessable_content
    end

    test 'should get edit' do
      sign_in_as(@admin)

      get "/admin/users/#{@standard_user.id}/edit"

      assert_response :success
    end

    test 'should update user' do
      sign_in_as(@admin)

      patch "/admin/users/#{@standard_user.id}", params: {
        user: {
          first_name: 'Johnny'
        }
      }

      @standard_user.reload

      assert_equal 'Johnny', @standard_user.first_name
      assert_redirected_to admin_users_url
      assert_equal I18n.t('admin.users.update.notice'), flash[:notice]
    end

    test 'should not update user with invalid params' do
      sign_in_as(@admin)

      patch "/admin/users/#{@standard_user.id}", params: {
        user: {
          first_name: ''
        }
      }

      assert_response :unprocessable_content
    end

    test 'should destroy user' do
      sign_in_as(@admin)

      assert_difference('User.count', -1) do
        delete "/admin/users/#{@standard_user.id}"
      end

      assert_redirected_to admin_users_url
      assert_equal I18n.t('admin.users.destroy.notice'), flash[:notice]
    end

    test 'should impersonate user' do
      sign_in_as(@admin)

      post "/admin/users/#{@standard_user.id}/impersonate"

      assert_redirected_to root_url
    end

    test 'should not impersonate super admin' do
      sign_in_as(@admin)

      post "/admin/users/#{@super_admin.id}/impersonate"

      assert_redirected_to root_url
      assert_equal I18n.t('action_policy.default'), flash[:alert]
    end

    test 'should stop impersonating' do
      sign_in_as(@admin)

      post '/admin/users/stop_impersonating'

      assert_redirected_to admin_users_url
    end

    test 'should redirect stop impersonating when unauthenticated' do
      post '/admin/users/stop_impersonating'

      assert_redirected_to new_session_url
    end
  end
end
