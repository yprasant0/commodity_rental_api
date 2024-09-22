class BidSerializer < ActiveModel::Serializer
  attributes :id, :monthly_price, :lease_period, :status, :created_at

  belongs_to :renter, serializer: UserSerializer
  belongs_to :commodity, serializer: CommoditySerializer
end
