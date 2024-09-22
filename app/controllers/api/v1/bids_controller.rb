module Api
  module V1
    class BidsController < ApplicationController

      before_action :ensure_renter, only: [:create, :update]

      def create
        result = Bids::CreateService.call(current_user, params[:commodity_id], bid_params)
        render_service_result(result)
      end

      def index
        if @commodity.nil?
          render json: { error: "Commodity not found" }, status: :not_found
          return
        end

        bids = @commodity.bids.includes(:renter)
        render json: bids, each_serializer: BidSerializer, status: :ok
      end

      def show
        render json: @bid, serializer: BidSerializer, status: :ok
      end

      def update
        result = Bids::UpdateService.call(@bid, current_user, bid_params)
        render_service_result(result)
      end

      private

      def set_commodity
        @commodity = Commodity.find(params[:commodity_id])
      end

      def bid_params
        params.permit(:bid_price_month, :rental_duration, :commodity_id, :bid)
      end

      def set_bid
        @bid = Bid.find(params[:id])
      end

      def ensure_renter
        unless current_user.renter?
          render json: { error: 'Only renters can perform this action' }, status: :unauthorized
        end
      end

      def render_service_result(result)
        if result.success
          render json: {
            status: "success",
            message: "Bid created successfully",
            payload: {
              bid_id: result.data[:bid].id,
              commodity_id: result.data[:bid].commodity_id,
              created_at: result.data[:bid].created_at
            }
          }, status: :created
        else
          render json: {
            status: "error",
            message: result.error,
            payload: {}
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
