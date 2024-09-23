module Bids
  class RebidService < ApplicationService
    def initialize(user, commodity_id, params)
      @user = user
      @commodity_id = commodity_id
      @params = params
    end

    def call
      commodity = Commodity.find_by(id: @commodity_id)
      return ServiceResult.error("Commodity not found", :not_found) unless commodity

      ActiveRecord::Base.transaction do
        commodity.with_lock do
          return ServiceResult.error("Commodity is not available for bidding", :unprocessable_entity) unless commodity.bidding?

          bid = commodity.bids.find_by(renter: @user)
          return ServiceResult.error("No existing bid found. Please use the bid API to place a new bid.", :not_found) unless bid

          if bid.update(monthly_price: @params[:bid_price_month], lease_period: @params[:rental_duration])
            ServiceResult.success({
                                    bid_id: bid.id,
                                    commodity_id: bid.commodity_id,
                                    bid_price_month: bid.monthly_price,
                                    rental_duration: bid.lease_period,
                                    created_at: bid.created_at
                                  })
          else
            ServiceResult.error(bid.errors.full_messages.join(", "), :unprocessable_entity)
          end
        end
      end
    rescue ActiveRecord::StaleObjectError
      ServiceResult.error("Concurrent update detected. Please refresh and try again.", :conflict)
    end
  end
end
