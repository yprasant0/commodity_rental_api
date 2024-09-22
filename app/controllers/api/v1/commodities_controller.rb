module Api
  module V1
    class CommoditiesController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_lender, only: [:create]

      def create
        result = Commodities::CreateService.call(current_user, commodity_params)
        Rails.logger.info "Result #{result.error} "
        if result.success
          render json: {
            status: "success",
            message: "Commodity listed successfully",
            payload: {
              commodity_id: result.data[:commodity].id,
              quote_price_per_month: result.data[:commodity].minimum_monthly_charge,
              created_at: result.data[:commodity].created_at
            }
          }, status: :created
        else
          render json: {
            status: "error",
            message: "Commodity could not be listed",
            payload: { errors: result.error }
          }, status: :unprocessable_entity
        end
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

