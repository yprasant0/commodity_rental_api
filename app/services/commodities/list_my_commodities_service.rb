module Commodities
  class ListMyCommoditiesService < ApplicationService
    def initialize(user)
      @user = user
    end

    def call
      commodities = @user.commodities.includes(:rental)
      commodities_data = commodities.map do |commodity|
        {
          commodity_id: commodity.id,
          created_at: commodity.created_at.to_i,
          quote_price_per_month: commodity.minimum_monthly_charge,
          category: commodity.category,
          status: commodity.status,
          accepted_bid_price: commodity.rental&.monthly_price,
          accepted_rented_period: commodity.rental&.lease_period
        }
      end

      ServiceResult.success(commodities_data)
    rescue StandardError => e
      ServiceResult.error("Failed to fetch commodities: #{e.message}")
    end
  end
end
