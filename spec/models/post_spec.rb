require 'rails_helper'

RSpec.describe 'Post#model', type: :model do
  let(:user) { create(:user) }
  let(:post) { Post.new(content: 'Lorem ipsum', user_id: user.id) }
  let(:post_params) { attributes_for(:post) }
  let(:invalid_post_params) { attributes_for(:post, content: '') }

  describe '新規作成' do
    it 'user_idとcontentがあれば有効であること' do
      expect(post).to be_valid
    end

    it 'user_idがnilであれば無効であること' do
      post.user_id = nil
      expect(post).not_to be_valid
    end

    it 'contentがnilであれば無効であること' do
      post.content = nil
      expect(post).not_to be_valid
    end

    it 'contentが空白であれば無効であること' do
      post.content = ''
      expect(post).not_to be_valid
    end
  end
end
