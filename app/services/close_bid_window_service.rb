class CloseBidWindowService < ApplicationService
  def initialize(commodity)
    @commodity = commodity
  end

  def call
    ActiveRecord::Base.transaction do
      @commodity.with_lock do
        return ServiceResult.error("Commodity is not in bidding state") unless @commodity.bidding?

        if Time.current > @commodity.bidding_start_time + 3.hours
          close_bidding
        else
          ServiceResult.error("Bidding window is still open")
        end
      end
    end
  rescue ActiveRecord::StaleObjectError
    ServiceResult.error("Concurrent update detected. Please try again.")
  rescue StandardError => e
    ServiceResult.error("An error occurred: #{e.message}")
  end

  private

  def close_bidding
    winning_bid = determine_winning_bid
    if winning_bid
      create_rental(winning_bid)
      ServiceResult.success(rental: winning_bid.rental)
    else
      @commodity.cancel!
      ServiceResult.success(message: "Bidding closed with no valid bids")
    end
  end

  def determine_winning_bid
    case @commodity.bid_strategy
    when 'highest_price'
      @commodity.bids.active.order(monthly_price: :desc).first
    when 'highest_overall'
      @commodity.bids.active.max_by { |bid| bid.monthly_price * bid.lease_period }
    end
  end

  def create_rental(winning_bid)
    rental = Rental.create!(
      commodity: @commodity,
      renter: winning_bid.renter,
      start_date: Date.today,
      end_date: Date.today + winning_bid.lease_period.months,
      monthly_price: winning_bid.monthly_price,
      status: :active
    )
    @commodity.rent!
    winning_bid.update!(status: :won, rental: rental)
    @commodity.bids.active.where.not(id: winning_bid.id).update_all(status: :lost)
    rental
  end
end
