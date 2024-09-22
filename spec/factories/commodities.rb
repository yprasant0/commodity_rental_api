FactoryBot.define do
  factory :commodity do
    name { "MyString" }
    description { "MyText" }
    category { "MyString" }
    minimum_monthly_charge { "9.99" }
    status { "MyString" }
    bid_strategy { "MyString" }
    lender { nil }
  end
end
