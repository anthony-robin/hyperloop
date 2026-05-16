require 'test_helper'

module Admin
  class DashboardsTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @standard_user = users(:standard)
    end

    test 'should get dashboard as admin' do
      sign_in_as(@admin)

      get '/admin/dashboard'

      assert_response :success
    end

    test 'should redirect dashboard for standard user' do
      sign_in_as(@standard_user)

      get '/admin/dashboard'

      assert_redirected_to root_url
      assert_equal I18n.t('action_policy.default'), flash[:alert]
    end

    test 'should redirect dashboard when unauthenticated' do
      get '/admin/dashboard'

      assert_redirected_to new_session_url
    end
  end
end
