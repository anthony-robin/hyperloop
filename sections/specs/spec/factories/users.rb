FactoryBot.define do
  factory :user do
    email_address { FFaker::Internet.email }
    password { 'password' }
    password_confirmation { password }
    first_name { FFaker::NameFR.first_name }
    last_name { FFaker::NameFR.last_name }
    role { :standard }

    trait :admin do
      role { :admin }
    end

    trait :super_admin do
      role { :super_admin }
    end
  end
end
