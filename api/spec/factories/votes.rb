FactoryBot.define do
  factory :vote do
    bnb { FactoryBot.build(:bnb) }
    number_of_votes { 1 }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
