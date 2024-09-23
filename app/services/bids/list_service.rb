module Bids
  class ListService < ApplicationService
    def initialize(commodity_id)
      @commodity_id = commodity_id
    end

    def call
      commodity = Commodity.find_by(id: @commodity_id)
      return ServiceResult.error("Commodity not found", :not_found) unless commodity

      bids = commodity.bids.map do |bid|
        {
          bid_id: bid.id,
          created_at: bid.created_at.to_i,
          bid_price_month: bid.monthly_price,
          rental_duration: bid.lease_period
        }
      end

      if bids.any?
        ServiceResult.success(bids)
      else
        ServiceResult.success([])
      end
    end
  end
end
