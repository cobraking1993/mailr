FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    sequence(:name) {|n| "User#{n}" }
    factory :fake_user do
      email { Faker::Internet.email }
      name { Faker::Name.name }
    end
    factory :invalid_user do
      email nil
      name nil
    end
  end
end

# password { (0...12).map { (65 + rand(26)).chr }.join + "aA1_" }
# roles { [] }
# points 0
# income 0
# ranking 0
# factory :admin do
#   email 'admin@example.com'
#   name 'Admin'
#   roles { ['admin'] }
#   password 'Towot2013!'
# end
# factory :moderator do
#   roles { ['moderator'] }
# end
# factory :test_user do
#   password 'Towot2014!'
# end
