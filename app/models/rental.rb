class Rental < ApplicationRecord
  include AASM

  belongs_to :commodity
  belongs_to :renter, class_name: 'User'

  enum status: { active: 'active', completed: 'completed', cancelled: 'cancelled' }

  validates :start_date, :end_date, :monthly_price, presence: true
  validates :monthly_price, numericality: { greater_than: 0 }
  validate :end_date_after_start_date

  aasm column: 'status' do
    state :active, initial: true
    state :completed
    state :cancelled

    event :complete do
      transitions from: :active, to: :completed
    end

    event :cancel do
      transitions from: :active, to: :cancelled
    end
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, "must be after the start date") if end_date < start_date
  end
end
