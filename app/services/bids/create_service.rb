module Bids
  class CreateService < ApplicationService
    def initialize(user, commodity_id, params)
      @user = user
      @commodity_id = commodity_id
      @params = params
    end

    def call
      commodity = Commodity.find_by(id: @commodity_id)
      return ServiceResult.error("Commodity not found", :not_found) if commodity.nil?

      bid = nil
      Bid.transaction do
        commodity.with_lock do
          return ServiceResult.error("Commodity is not available for bidding", :unprocessable_entity) unless commodity.bidding?

          bid = commodity.bids.new(
            renter: @user,
            monthly_price: @params[:bid_price_month],
            lease_period: @params[:rental_duration]
          )
          if bid.save
            ServiceResult.success(bid: bid)
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
