FactoryBot.define do
  factory :bid do
    monthly_price { "9.99" }
    lease_period { 1 }
    status { "MyString" }
    commodity { nil }
    renter { nil }
  end
end
