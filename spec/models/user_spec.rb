require 'rails_helper'

RSpec.describe User, type: :model do
  example 'ユーザー登録' do
    it "user_id、passwordとpassword_confirmationが存在すれば登録できること" do
      user = build(:user)
      expect(user).to be_valid  # user.valid? が true になればパスする
    end
  end
end
