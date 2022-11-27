require 'rails_helper'
RSpec.describe "User#system", type: :system do
  let(:user) { create(:user) }

  describe 'ページ遷移確認' do
    context 'ユーザーの新規作成ページに遷移' do
      it 'ユーザー新規作成ページへのアクセスに成功すること' do
        visit new_user_registration_path
        expect(page).to have_content 'ユーザー新規作成'
        expect(current_path).to eq new_user_registration_path
      end
    end

    context 'ユーザーの設定ページに遷移' do
      it 'ユーザー設定ページへのアクセスに成功すること' do
        sign_in(user)
        visit edit_user_registration_path(user)
        expect(page).to have_content 'ユーザー設定'
        expect(page).to have_field 'user_email', with: user.email
        expect(page).to have_field 'user_password'
        expect(page).to have_field 'user_password_confirmation'
        expect(page).to have_field 'user_current_password'
        expect(current_path).to eq edit_user_registration_path(user)
      end
    end
  end
end
