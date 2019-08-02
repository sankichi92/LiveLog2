FactoryBot.define do
  factory :identity do
    user
    provider { 'google_oauth2' }
    uid { Faker::Number.number(digits: 21).to_s }
  end
end
