require 'rails_helper'

RSpec.describe 'User#model', type: :model do
  let(:user) { build(:user) }
  let(:user_params) { attributes_for(:user) }
  let(:invalid_user_params) { attributes_for(:user, company_id: '') }

  describe 'ユーザー登録' do
    it 'company_id、passwordとpassword_confirmationが存在すれば登録できること' do
      expect(user).to be_valid
    end

    it 'company_idがnilの場合、userは無効であること' do
      user.company_id = nil
      expect(user).not_to be_valid
    end

    it 'passwordがnilの場合、userは無効であること' do
      user.password = nil
      expect(user).not_to be_valid
    end

    it 'company_idが空白の場合、userは無効であること' do
      user.company_id = ''
      expect(user).not_to be_valid
    end

    it 'passwordが空白の場合、userは無効であること' do
      user.password = ''
      expect(user).not_to be_valid
    end
  end
end
