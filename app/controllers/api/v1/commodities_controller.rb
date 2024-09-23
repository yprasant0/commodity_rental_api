module Api
  module V1
    class CommoditiesController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_lender, only: [:create, :re_list]

      def create
        result = Commodities::CreateService.call(current_user, commodity_params)
        render_service_result(result)
      end

      def re_list
        result = Commodities::RelistService.call(current_user, params[:commodity_id], relist_params)
        render_service_result(result)
      end


      def index
        commodities = if params[:category].present?
                        Commodity.available.where(category: params[:category])
                      else
                        Commodity.available
                      end

        render json: {
          status: "success",
          message: "Available commodities fetched successfully",
          payload: commodities.map do |commodity|
            {
              commodity_id: commodity.id,
              created_at: commodity.created_at.to_i,
              minimum_monthly_charge: commodity.minimum_monthly_charge,
              category: commodity.category
            }
          end
        }
      end

      private

      def commodity_params
        params.require(:commodity).permit(:name, :description, :minimum_monthly_charge, :category, :bid_strategy)
      end

      def relist_params
        params.permit(:quote_price_per_month)
      end

      def render_service_result(result)
        if result.success
          render json: {
            status: "success",
            message: "Operation completed successfully",
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

      def ensure_lender
        unless current_user.lender?
          render json: {
            status: "error",
            message: "Only lenders can list commodities",
            payload: {}
          }, status: :unauthorized
        end
      end
    end
  end
end

