FactoryBot.define do
  factory :rental do
    start_date { "2024-09-22" }
    end_date { "2024-09-22" }
    monthly_price { "9.99" }
    status { "MyString" }
    commodity { nil }
    renter { nil }
  end
end
