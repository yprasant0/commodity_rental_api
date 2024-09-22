class BidsController < ApplicationController
  before_action :set_bid, only: [:show, :update]
  before_action :ensure_renter, only: [:create, :update]

  def index
    @bids = current_user.bids
    render json: @bids
  end

  def show
    render json: @bid
  end

  def create
    result = Bids::CreateService.call(current_user, params[:commodity_id], bid_params)
    if result.success?
      render json: result.data[:bid], status: :created
    else
      render json: { errors: result.error }, status: :unprocessable_entity
    end
  end

  def update
    result = Bids::UpdateService.call(@bid, current_user, bid_params)
    if result.success?
      render json: result.data[:bid]
    else
      render json: { errors: result.error }, status: :unprocessable_entity
    end
  end

  private

  def set_bid
    @bid = current_user.bids.find(params[:id])
  end

  def bid_params
    params.require(:bid).permit(:monthly_price, :lease_period)
  end

  def ensure_renter
    unless current_user.renter?
      render json: { error: 'Only renters can perform this action' }, status: :unauthorized
    end
  end
end
