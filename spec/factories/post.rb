FactoryBot.define do
  factory :post do
    content { "My string" }
    association :user
  end
end
