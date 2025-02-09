def sign_in(user)
  post session_url, params: {
    email_address: user.email_address,
    password: 'password'
  }
end
