module Commodities
  class RelistService < ApplicationService
    def initialize(user, commodity_id, params)
      @user = user
      @commodity_id = commodity_id
      @params = params
    end

    def call
      commodity = @user.commodities.find_by(id: @commodity_id)
      return ServiceResult.error("Commodity not found") unless commodity

      ActiveRecord::Base.transaction do
        commodity.with_lock do
          if commodity.may_make_available?
            commodity.make_available!
            update_quote_price(commodity) if @params[:quote_price_per_month].present?
            if commodity.start_bidding!
              ServiceResult.success(format_commodity(commodity))
            else
              ServiceResult.error("Failed to start bidding")
            end
          else
            ServiceResult.error("Cannot relist the commodity in its current state")
          end
        end
      end
    rescue ActiveRecord::StaleObjectError
      ServiceResult.error("Concurrent update detected. Please refresh and try again.")
    rescue StandardError => e
      ServiceResult.error("An error occurred: #{e.message}")
    end

    private

    def update_quote_price(commodity)
      commodity.update!(minimum_monthly_charge: @params[:quote_price_per_month])
    end

    def format_commodity(commodity)
      {
        commodity_id: commodity.id,
        quote_price_per_month: commodity.minimum_monthly_charge,
        created_at: commodity.created_at,
        updated_at: commodity.updated_at
      }
    end
  end
end
