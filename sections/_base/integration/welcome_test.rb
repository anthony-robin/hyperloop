require 'test_helper'

class WelcomeTest < ActionDispatch::IntegrationTest
  test 'should get homepage' do
    get '/'

    assert_response :success
  end
end
