FactoryBot.define do
  factory :user do
    sequence(:company_id) { |n| "12121#{n}" }
    password              { "password" }
    password_confirmation { "password" }
  end
end
