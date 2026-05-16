require 'test_helper'

class PasswordsTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.take
  end

  test 'should get new password form' do
    get '/passwords/new'

    assert_response :success
  end

  test 'should create password reset request' do
    post '/passwords', params: {
      email_address: @user.email_address
    }

    assert_enqueued_email_with PasswordsMailer, :reset, args: [@user]
    assert_redirected_to '/session/new'

    follow_redirect!

    assert_notice 'reset instructions sent'
  end

  test 'should handle unknown user gracefully' do
    post '/passwords', params: {
      email_address: 'missing-user@example.com'
    }

    assert_enqueued_emails 0
    assert_redirected_to '/session/new'

    follow_redirect!

    assert_notice 'reset instructions sent'
  end

  test 'should get edit password form with valid token' do
    get "/passwords/#{@user.password_reset_token}/edit"

    assert_response :success
  end

  test 'should redirect when token is invalid' do
    get '/passwords/invalid-token/edit'

    assert_redirected_to '/passwords/new'

    follow_redirect!

    assert_notice 'reset link is invalid'
  end

  test 'should update password with valid token' do
    assert_changes -> { @user.reload.password_digest } do
      put "/passwords/#{@user.password_reset_token}", params: {
        password: 'new',
        password_confirmation: 'new'
      }

      assert_redirected_to '/session/new'
    end

    follow_redirect!

    assert_notice 'Password has been reset'
  end

  test 'should not update password when confirmation does not match' do
    token = @user.password_reset_token

    assert_no_changes -> { @user.reload.password_digest } do
      patch "/passwords/#{token}", params: {
        password: 'no',
        password_confirmation: 'match'
      }

      assert_redirected_to "/passwords/#{token}/edit"
    end

    follow_redirect!

    assert_notice 'Passwords did not match'
  end

  private

  def assert_notice(text)
    assert_select 'div', /#{text}/
  end
end
