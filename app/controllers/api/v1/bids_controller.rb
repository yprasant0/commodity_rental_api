module Api
  module V1
    class BidsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_renter, only: [:create, :re_bid]

      def create
        result = Bids::CreateService.call(current_user, params[:commodity_id], bid_params)
        render_service_result(result)
      end

      def re_bid
        result = Bids::RebidService.call(current_user, params[:commodity_id], bid_params)
        render_service_result(result)
      end

      def index
        result = Bids::ListService.call(params[:id])
        render_service_result(result)
      end

      private

      def bid_params
        params.permit(:bid_price_month, :rental_duration)
      end

      def ensure_renter
        head :unauthorized unless current_user.renter?
      end

      def render_service_result(result)
        if result.success
          render json: {
            status: "success",
            message: "Request processed successfully",
            payload: result.data
          }, status: :ok
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
