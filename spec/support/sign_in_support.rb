module SignInSupport
  def sign_in(user)
    visit new_user_session_path
    fill_in 'user_company_id', with: user.company_id
    fill_in 'user_password', with: 'password'
    click_button 'Log in'
  end
end
