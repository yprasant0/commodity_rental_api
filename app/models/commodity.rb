class Commodity < ApplicationRecord
  include AASM

  belongs_to :lender, class_name: 'User'
  has_many :bids, dependent: :destroy
  has_one :rental

  CATEGORIES = ['Electronic Appliances', 'Electronic Accessories', 'Furniture', 'Men\'s wear', 'Women\'s wear', 'Shoes'].freeze

  enum status: { available: 'available', bidding: 'bidding', rented: 'rented' }

  enum bid_strategy: { highest_price: 'highest_price', highest_overall: 'highest_overall' }

  validates :name, :description, :minimum_monthly_charge, :bid_strategy, presence: true
  validates :minimum_monthly_charge, numericality: { greater_than: 0 }
  validates :category, inclusion: { in: CATEGORIES }

  scope :available, -> { where(status: [:available, :bidding]) }

  aasm column: 'status' do
    state :available, initial: true
    state :bidding
    state :rented
    state :cancelled

    event :start_bidding do
      transitions from: :available, to: :bidding do
        after do
          update(bidding_start_time: Time.current)
          CloseBidWindowJob.schedule(self)
        end
      end
    end

    event :rent do
      transitions from: :bidding, to: :rented
    end

    event :make_available do
      transitions from: [:bidding, :rented, :cancelled], to: :available
    end

    event :cancel do
      transitions from: :bidding, to: :cancelled
    end
  end

  private

  def bidding_window_open?
    bidding? && Time.current < (updated_at + 3.hours)
  end
end
