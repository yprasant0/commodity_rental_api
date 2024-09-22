class User < ApplicationRecord
  include AASM
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenyEntry

  ROLES = %w[renter lender].freeze

  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role" }
  validates :first_name, :last_name, presence: true

  has_many :commodities, foreign_key: :lender_id, dependent: :destroy
  has_many :bids, foreign_key: :renter_id, dependent: :destroy
  has_many :rentals, foreign_key: :renter_id, dependent: :destroy

  # aasm column: 'role' do
  #   state :renter, initial: true
  #   state :lender
  #
  #   event :make_lender do
  #     transitions from: :renter, to: :lender
  #   end
  #
  #   event :make_renter do
  #     transitions from: :lender, to: :renter
  #   end
  # end
  def lender?
    role == 'lender'
  end

  def renter?
    role == 'renter'
  end

  def generate_jwt
    JWT.encode({ id: id, exp: 60.days.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end
end

