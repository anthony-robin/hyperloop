require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
  end

  test 'should get new session' do
    get '/session/new'

    assert_response :success
  end

  test 'should create session with valid credentials' do
    post '/session', params: {
      email_address: @user.email_address,
      password: 'password'
    }

    assert_redirected_to root_url
    assert cookies[:session_id]
  end

  test 'should not create session with invalid credentials' do
    post '/session', params: {
      email_address: @user.email_address,
      password: 'wrong'
    }

    assert_redirected_to '/session/new'
    assert_nil cookies[:session_id]
  end

  test 'should destroy session' do
    sign_in_as(@user)

    delete '/session'

    assert_redirected_to '/session/new'
    assert_empty cookies[:session_id]
  end
end
