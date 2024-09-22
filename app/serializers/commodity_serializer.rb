class CommoditySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :minimum_monthly_charge, :category, :status, :created_at


  belongs_to :lender
  has_many :bids

  def id
    object.id.to_s
  end
end
