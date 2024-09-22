class CloseBidWindowService < ApplicationService
  def initialize(commodity)
    @commodity = commodity
  end

  def call
    ActiveRecord::Base.transaction do
      @commodity.lock!
      return unless @commodity.bidding?

      winning_bid = determine_winning_bid
      if winning_bid
        create_rental(winning_bid)
      else
        @commodity.make_available!
      end
    end
  rescue ActiveRecord::StaleObjectError
    # Log the error and potentially retry
    Rails.logger.error("Stale object error when closing bid for commodity #{@commodity.id}")
  rescue AASM::InvalidTransition => e
    Rails.logger.error("Invalid state transition for commodity #{@commodity.id}: #{e.message}")
  end

  private

  def determine_winning_bid
    case @commodity.bid_strategy
    when 'highest_price'
      @commodity.bids.order(monthly_price: :desc).first
    when 'highest_overall'
      @commodity.bids.max_by { |bid| bid.monthly_price * bid.lease_period }
    end
  end

  def create_rental(winning_bid)
    Rental.create!(
      commodity: @commodity,
      renter: winning_bid.renter,
      start_date: Date.today,
      end_date: Date.today + winning_bid.lease_period.months,
      monthly_price: winning_bid.monthly_price,
      status: :active
    )
    @commodity.rent!
    winning_bid.win!
    @commodity.bids.where.not(id: winning_bid.id).update_all(status: :lost)
  end
end
