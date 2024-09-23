class RentalSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :monthly_price, :status
  belongs_to :commodity
  belongs_to :renter
end
