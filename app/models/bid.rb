class Bid < ApplicationRecord
  include AASM

  belongs_to :commodity
  belongs_to :renter, class_name: 'User'

  enum status: { active: 'active', won: 'won', lost: 'lost', cancelled: 'cancelled' }

  validates :monthly_price, :lease_period, presence: true
  validates :monthly_price, numericality: { greater_than_or_equal_to: :minimum_monthly_charge }
  validates :lease_period, numericality: { greater_than: 0 }

  validate :renter_cannot_bid_on_own_commodity
  validate :commodity_must_be_in_bidding_state
  validate :renter_cannot_be_lender

  aasm column: 'status' do
    state :active, initial: true
    state :won
    state :lost
    state :cancelled

    event :win do
      transitions from: :active, to: :won
    end

    event :lose do
      transitions from: :active, to: :lost
    end

    event :cancel do
      transitions from: :active, to: :cancelled
    end
  end

  private

  def minimum_monthly_charge
    commodity.minimum_monthly_charge
  end

  def renter_cannot_bid_on_own_commodity
    errors.add(:base, "You cannot bid on your own commodity") if renter == commodity.lender
  end

  def commodity_must_be_in_bidding_state
    errors.add(:base, "Commodity is not available for bidding") unless commodity.bidding?
  end

  def renter_cannot_be_lender
    errors.add(:base, "Lenders cannot place bids") if renter.lender?
  end
end
