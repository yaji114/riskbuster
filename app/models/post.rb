class Post < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  scope :descorder, -> { order(created_at: :desc) }
  validates :content, presence: true, length: { maximum: 400 }
end
