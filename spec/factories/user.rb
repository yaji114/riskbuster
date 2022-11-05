FactoryBot.define do
  factory :user do
    user_id               { "1212121212" }
    password              { "111111" }
    password_confirmation { "111111" }
  end
end
